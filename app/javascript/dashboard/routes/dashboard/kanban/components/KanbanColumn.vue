<script setup>
import Button from 'dashboard/components-next/button/Button.vue';
import KanbanCard from './KanbanCard.vue';

const props = defineProps({
  column: { type: Object, required: true },
  pipelineId: { type: [Number, String], required: true },
});

const emit = defineEmits(['card-dropped', 'add-card', 'delete-column', 'edit-column']);

const cards = computed(() => props.column.kanban_cards || []);

const onDragStart = (card, event) => {
  event.dataTransfer.setData(
    'application/json',
    JSON.stringify({ cardId: card.id, fromColumnId: props.column.id })
  );
};

const onDrop = event => {
  const raw = event.dataTransfer.getData('application/json');
  if (!raw) return;
  const { cardId, fromColumnId } = JSON.parse(raw);
  emit('card-dropped', {
    cardId,
    fromColumnId,
    toColumnId: props.column.id,
    position: cards.value.length,
  });
};
</script>

<script>
import { computed } from 'vue';
</script>

<template>
  <div
    class="flex flex-col min-w-[272px] max-w-[272px] bg-n-alpha-1 rounded-xl overflow-hidden border border-n-weak"
    @dragover.prevent
    @drop="onDrop"
  >
    <!-- Column Header -->
    <div
      class="flex items-center gap-2 px-3 py-2 bg-n-background border-b border-n-weak"
      :style="{ borderTopColor: column.color, borderTopWidth: '3px', borderTopStyle: 'solid' }"
    >
      <span class="flex-1 text-sm font-semibold text-n-slate-12 truncate">{{ column.name }}</span>
      <span class="text-xs text-n-slate-10 bg-n-alpha-2 rounded-full px-1.5 py-0.5">{{ cards.length }}</span>
      <Button icon="i-lucide-pencil" size="xs" variant="ghost" color="slate" @click="emit('edit-column', column)" />
      <Button icon="i-lucide-trash-2" size="xs" variant="ghost" color="ruby" @click="emit('delete-column', column.id)" />
    </div>

    <!-- Cards -->
    <div class="flex flex-col gap-2 p-2 flex-1 overflow-y-auto min-h-[60px]">
      <KanbanCard
        v-for="card in cards"
        :key="card.id"
        :card="card"
        :pipeline-id="pipelineId"
        :column-id="column.id"
        :sla-minutes="column.sla_minutes"
        draggable="true"
        @dragstart="onDragStart(card, $event)"
      />
    </div>

    <!-- Footer -->
    <div class="px-2 py-1.5 border-t border-n-weak">
      <Button
        icon="i-lucide-plus"
        size="xs"
        variant="ghost"
        color="slate"
        :label="$t('KANBAN.ADD_CARD')"
        justify="start"
        class="w-full"
        @click="emit('add-card', column.id)"
      />
    </div>
  </div>
</template>
