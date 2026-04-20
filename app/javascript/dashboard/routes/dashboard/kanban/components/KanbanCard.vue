<script setup>
import { computed } from 'vue';
import { useStore } from 'vuex';
import { useRouter } from 'vue-router';
import Button from 'dashboard/components-next/button/Button.vue';
import { frontendURL, conversationUrl } from 'dashboard/helper/URLHelper';

const props = defineProps({
  card: { type: Object, required: true },
  pipelineId: { type: [Number, String], required: true },
  columnId: { type: [Number, String], required: true },
});

const emit = defineEmits(['dragstart']);

const store = useStore();
const router = useRouter();

const accountId = computed(() => store.getters['getCurrentAccountId']);
const conversation = computed(() => props.card.conversation || {});

const statusClass = computed(() => {
  const map = {
    open: 'bg-n-teal-9/10 text-n-teal-11',
    resolved: 'bg-n-brand/10 text-n-blue-11',
    pending: 'bg-n-amber-9/10 text-n-amber-11',
    snoozed: 'bg-n-alpha-2 text-n-slate-11',
  };
  return map[conversation.value.status] || 'bg-n-alpha-2 text-n-slate-11';
});

const conversationLink = computed(() => {
  if (!conversation.value.id) return null;
  return frontendURL(
    conversationUrl({ accountId: accountId.value, id: conversation.value.id })
  );
});

const senderName = computed(() => conversation.value.meta?.sender?.name || '');
const assigneeName = computed(() => conversation.value.meta?.assignee?.name || '');
const inboxName = computed(() => conversation.value.meta?.channel || '');

const openConversation = () => {
  if (conversationLink.value) router.push(conversationLink.value);
};

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
    class="bg-n-background rounded-lg p-3 shadow-sm border border-n-weak cursor-grab active:cursor-grabbing group"
    draggable="true"
    @dragstart="emit('dragstart', $event)"
  >
    <!-- Header: ID + status -->
    <div class="flex items-center justify-between mb-2">
      <button
        class="text-xs font-semibold text-n-brand hover:underline cursor-pointer bg-transparent border-0 p-0"
        @click.stop="openConversation"
      >
        #{{ conversation.display_id }}
      </button>
      <span class="text-xs px-1.5 py-0.5 rounded-full capitalize font-medium" :class="statusClass">
        {{ conversation.status }}
      </span>
    </div>

    <!-- Contact name -->
    <p v-if="senderName" class="text-sm font-semibold text-n-slate-12 m-0 mb-1 truncate">
      {{ senderName }}
    </p>

    <!-- Assignee -->
    <div v-if="assigneeName" class="flex items-center gap-1 mb-1">
      <span class="i-lucide-user-round size-3 text-n-slate-10 flex-shrink-0" />
      <span class="text-xs text-n-slate-11 truncate">{{ assigneeName }}</span>
    </div>

    <!-- Inbox -->
    <div v-if="inboxName" class="flex items-center gap-1 mb-1">
      <span class="i-lucide-inbox size-3 text-n-slate-10 flex-shrink-0" />
      <span class="text-xs text-n-slate-10 truncate">{{ inboxName }}</span>
    </div>

    <!-- Notes -->
    <p v-if="card.notes" class="text-xs text-n-slate-11 m-0 mt-1 mb-1 line-clamp-2 italic">
      {{ card.notes }}
    </p>

    <!-- Actions -->
    <div class="flex items-center justify-between mt-2 opacity-0 group-hover:opacity-100 transition-opacity">
      <Button
        icon="i-lucide-external-link"
        size="xs"
        variant="ghost"
        color="slate"
        :title="'Abrir conversa'"
        @click.stop="openConversation"
      />
      <Button
        icon="i-lucide-trash-2"
        size="xs"
        variant="ghost"
        color="ruby"
        @click.stop="onDelete"
      />
    </div>
  </div>
</template>
