<script setup>
import { computed } from 'vue';
import { useStore } from 'vuex';
import Button from 'dashboard/components-next/button/Button.vue';

const props = defineProps({
  card: { type: Object, required: true },
  pipelineId: { type: [Number, String], required: true },
  columnId: { type: [Number, String], required: true },
});

const emit = defineEmits(['dragstart']);

const store = useStore();

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
    <div class="flex items-center justify-between mb-1.5">
      <span class="text-xs font-semibold text-n-slate-10">#{{ conversation.display_id }}</span>
      <span class="text-xs px-1.5 py-0.5 rounded-full capitalize" :class="statusClass">
        {{ conversation.status }}
      </span>
    </div>

    <p v-if="conversation.meta?.sender?.name" class="text-sm font-medium text-n-slate-12 m-0 mb-1 truncate">
      {{ conversation.meta.sender.name }}
    </p>

    <p v-if="card.notes" class="text-xs text-n-slate-11 m-0 mb-2 line-clamp-2">
      {{ card.notes }}
    </p>

    <div class="flex justify-end opacity-0 group-hover:opacity-100 transition-opacity">
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
