<script setup>
import { computed, ref, onMounted, onUnmounted } from 'vue';
import { useStore } from 'vuex';
import { useRouter } from 'vue-router';
import { frontendURL, conversationUrl } from 'dashboard/helper/URLHelper';

const props = defineProps({
  card: { type: Object, required: true },
  pipelineId: { type: [Number, String], required: true },
  columnId: { type: [Number, String], required: true },
  slaMinutes: { type: Number, default: null },
});

const emit = defineEmits(['dragstart']);
const store = useStore();
const router = useRouter();

const accountId = computed(() => store.getters['getCurrentAccountId']);
const conversation = computed(() => props.card.conversation || {});

// ── Priority ──────────────────────────────────────────────────────────────────
const PRIORITIES = [
  { value: null,     label: 'Sem prioridade', icon: 'i-lucide-minus',          color: 'text-n-slate-9' },
  { value: 'low',    label: 'Baixa',          icon: 'i-lucide-arrow-down',      color: 'text-n-teal-11' },
  { value: 'medium', label: 'Média',          icon: 'i-lucide-arrow-right',     color: 'text-n-amber-11' },
  { value: 'high',   label: 'Alta',           icon: 'i-lucide-arrow-up',        color: 'text-n-ruby-11' },
  { value: 'urgent', label: 'Urgente',        icon: 'i-lucide-alert-triangle',  color: 'text-n-ruby-11 animate-pulse' },
];

const currentPriority = computed(() =>
  PRIORITIES.find(p => p.value === (conversation.value.priority || null)) || PRIORITIES[0]
);

const showPriorityMenu = ref(false);

const setPriority = async priority => {
  showPriorityMenu.value = false;
  try {
    await fetch(
      `/api/v1/accounts/${accountId.value}/conversations/${conversation.value.id}/toggle_priority`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'api_access_token': store.getters['auth/getCurrentUser']?.access_token },
        body: JSON.stringify({ priority }),
      }
    );
    // Update local state optimistically
    if (props.card.conversation) props.card.conversation.priority = priority;
  } catch (e) { /* silent */ }
};

// ── Status ────────────────────────────────────────────────────────────────────
const statusClass = computed(() => {
  const map = {
    open:     'bg-n-teal-9/10 text-n-teal-11',
    resolved: 'bg-n-brand/10 text-n-blue-11',
    pending:  'bg-n-amber-9/10 text-n-amber-11',
    snoozed:  'bg-n-alpha-2 text-n-slate-11',
  };
  return map[conversation.value.status] || 'bg-n-alpha-2 text-n-slate-11';
});

// ── Timer ─────────────────────────────────────────────────────────────────────
const now = ref(Date.now());
let timerInterval = null;

onMounted(() => { timerInterval = setInterval(() => { now.value = Date.now(); }, 30_000); });
onUnmounted(() => clearInterval(timerInterval));

const elapsedMs = computed(() => {
  const since = props.card.entered_column_at || props.card.created_at;
  if (!since) return 0;
  return now.value - new Date(since).getTime();
});

const elapsedLabel = computed(() => {
  const ms = elapsedMs.value;
  const mins = Math.floor(ms / 60_000);
  if (mins < 60) return `${mins}m`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `${hrs}h`;
  return `${Math.floor(hrs / 24)}d`;
});

// green → yellow (>50% SLA) → red (>100% SLA)
const timerClass = computed(() => {
  if (!props.slaMinutes) return 'text-n-slate-10';
  const pct = elapsedMs.value / (props.slaMinutes * 60_000);
  if (pct >= 1)   return 'text-n-ruby-11 font-semibold';
  if (pct >= 0.5) return 'text-n-amber-11';
  return 'text-n-teal-11';
});

const timerIcon = computed(() => {
  if (!props.slaMinutes) return 'i-lucide-clock';
  const pct = elapsedMs.value / (props.slaMinutes * 60_000);
  if (pct >= 1)   return 'i-lucide-alarm-clock-off';
  if (pct >= 0.5) return 'i-lucide-alarm-clock';
  return 'i-lucide-clock';
});

// ── Navigation ────────────────────────────────────────────────────────────────
const openConversation = () => {
  if (!conversation.value.id) return;
  router.push(frontendURL(conversationUrl({ accountId: accountId.value, id: conversation.value.id })));
};

// ── Delete ────────────────────────────────────────────────────────────────────
const onDelete = () => {
  store.dispatch('kanban/deleteCard', {
    pipelineId: props.pipelineId,
    cardId: props.card.id,
    columnId: props.columnId,
  });
};
</script>

<template>
  <div
    class="relative bg-n-background rounded-lg border border-n-weak shadow-sm cursor-grab active:cursor-grabbing group transition-shadow hover:shadow-md"
    draggable="true"
    @dragstart="emit('dragstart', $event)"
  >
    <!-- Priority color bar -->
    <div
      class="absolute top-0 left-0 w-1 h-full rounded-l-lg"
      :class="{
        'bg-n-ruby-9':  conversation.priority === 'urgent' || conversation.priority === 'high',
        'bg-n-amber-9': conversation.priority === 'medium',
        'bg-n-teal-9':  conversation.priority === 'low',
        'bg-n-alpha-3': !conversation.priority,
      }"
    />

    <div class="pl-3 pr-2 pt-2 pb-2">
      <!-- Row 1: ID + status + delete -->
      <div class="flex items-center gap-1.5 mb-1.5">
        <button
          class="text-xs font-bold text-n-brand hover:underline bg-transparent border-0 p-0 cursor-pointer"
          @click.stop="openConversation"
        >
          #{{ conversation.display_id }}
        </button>
        <span class="text-xs px-1.5 py-0.5 rounded-full capitalize font-medium flex-shrink-0" :class="statusClass">
          {{ conversation.status }}
        </span>
        <div class="flex-1" />
        <button
          class="opacity-0 group-hover:opacity-100 transition-opacity p-0.5 rounded hover:bg-n-ruby-9/10 text-n-slate-9 hover:text-n-ruby-11"
          @click.stop="onDelete"
        >
          <span class="i-lucide-x size-3 block" />
        </button>
      </div>

      <!-- Row 2: Contact name -->
      <p v-if="conversation.contact?.name" class="text-sm font-semibold text-n-slate-12 m-0 mb-1 truncate leading-tight">
        {{ conversation.contact.name }}
      </p>

      <!-- Row 3: Assignee + Inbox -->
      <div class="flex items-center gap-2 mb-1.5 flex-wrap">
        <div v-if="conversation.assignee?.name" class="flex items-center gap-1">
          <span class="i-lucide-user-round size-3 text-n-slate-9" />
          <span class="text-xs text-n-slate-11 truncate max-w-[80px]">{{ conversation.assignee.name }}</span>
        </div>
        <div v-if="conversation.inbox?.name" class="flex items-center gap-1">
          <span class="i-lucide-inbox size-3 text-n-slate-9" />
          <span class="text-xs text-n-slate-10 truncate max-w-[80px]">{{ conversation.inbox.name }}</span>
        </div>
      </div>

      <!-- Notes -->
      <p v-if="card.notes" class="text-xs text-n-slate-11 m-0 mb-1.5 line-clamp-2 italic">
        {{ card.notes }}
      </p>

      <!-- Row 4: Priority picker + Timer -->
      <div class="flex items-center justify-between mt-1">
        <!-- Priority -->
        <div class="relative">
          <button
            class="flex items-center gap-1 px-1.5 py-0.5 rounded hover:bg-n-alpha-2 transition-colors"
            :title="currentPriority.label"
            @click.stop="showPriorityMenu = !showPriorityMenu"
          >
            <span class="size-3.5 block flex-shrink-0" :class="[currentPriority.icon, currentPriority.color]" />
            <span class="text-xs" :class="currentPriority.color">{{ currentPriority.label }}</span>
          </button>

          <!-- Priority dropdown -->
          <div
            v-if="showPriorityMenu"
            class="absolute bottom-full left-0 mb-1 bg-n-background border border-n-weak rounded-lg shadow-lg z-50 py-1 min-w-[130px]"
            @click.stop
          >
            <button
              v-for="p in PRIORITIES"
              :key="p.value ?? 'none'"
              class="flex items-center gap-2 w-full px-3 py-1.5 text-xs hover:bg-n-alpha-2 transition-colors text-left"
              :class="{ 'bg-n-alpha-2': (conversation.priority || null) === p.value }"
              @click.stop="setPriority(p.value)"
            >
              <span class="size-3.5 block flex-shrink-0" :class="[p.icon, p.color]" />
              <span :class="p.color">{{ p.label }}</span>
            </button>
          </div>
        </div>

        <!-- Timer -->
        <div class="flex items-center gap-1" :class="timerClass" :title="`Tempo nesta coluna: ${elapsedLabel}`">
          <span class="size-3 block flex-shrink-0" :class="timerIcon" />
          <span class="text-xs tabular-nums">{{ elapsedLabel }}</span>
        </div>
      </div>
    </div>
  </div>
</template>
