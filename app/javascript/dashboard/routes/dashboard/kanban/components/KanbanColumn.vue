<template>
  <div
    class="kanban-column"
    @dragover.prevent
    @drop="onDrop"
  >
    <div class="column-header" :style="{ borderTopColor: column.color }">
      <span class="column-name">{{ column.name }}</span>
      <span class="column-count">{{ cards.length }}</span>
      <div class="column-actions">
        <woot-button size="tiny" variant="clear" icon="edit" @click="$emit('edit-column', column)" />
        <woot-button size="tiny" variant="clear" icon="delete" color-scheme="alert" @click="$emit('delete-column', column.id)" />
      </div>
    </div>

    <div class="column-cards">
      <kanban-card
        v-for="card in cards"
        :key="card.id"
        :card="card"
        :pipeline-id="pipelineId"
        :column-id="column.id"
        draggable="true"
        @dragstart="onDragStart(card, $event)"
      />
    </div>

    <div class="column-footer">
      <woot-button
        size="small"
        variant="clear"
        icon="add"
        @click="$emit('add-card', column.id)"
      >
        {{ $t('KANBAN.ADD_CARD') }}
      </woot-button>
    </div>
  </div>
</template>

<script>
import KanbanCard from './KanbanCard.vue';

export default {
  name: 'KanbanColumn',
  components: { KanbanCard },

  props: {
    column: { type: Object, required: true },
    pipelineId: { type: [Number, String], required: true },
  },

  emits: ['card-dropped', 'add-card', 'delete-column', 'edit-column'],

  computed: {
    cards() {
      return this.column.kanban_cards || [];
    },
  },

  methods: {
    onDragStart(card, event) {
      event.dataTransfer.setData(
        'application/json',
        JSON.stringify({ cardId: card.id, fromColumnId: this.column.id })
      );
    },

    onDrop(event) {
      const raw = event.dataTransfer.getData('application/json');
      if (!raw) return;
      const { cardId, fromColumnId } = JSON.parse(raw);
      this.$emit('card-dropped', {
        cardId,
        fromColumnId,
        toColumnId: this.column.id,
        position: this.cards.length,
      });
    },
  },
};
</script>

<style lang="scss" scoped>
.kanban-column {
  display: flex;
  flex-direction: column;
  min-width: 280px;
  max-width: 280px;
  background: var(--color-background-light);
  border-radius: var(--border-radius-normal);
  overflow: hidden;
}

.column-header {
  display: flex;
  align-items: center;
  gap: var(--space-small);
  padding: var(--space-small) var(--space-normal);
  border-top: 3px solid var(--color-woot);
  background: var(--white);
}

.column-name {
  flex: 1;
  font-weight: var(--font-weight-bold);
  font-size: var(--font-size-small);
}

.column-count {
  background: var(--color-background);
  border-radius: 10px;
  padding: 0 var(--space-smaller);
  font-size: var(--font-size-mini);
  color: var(--color-body);
}

.column-actions {
  display: flex;
  gap: 2px;
}

.column-cards {
  flex: 1;
  overflow-y: auto;
  padding: var(--space-small);
  display: flex;
  flex-direction: column;
  gap: var(--space-small);
  min-height: 60px;
}

.column-footer {
  padding: var(--space-smaller) var(--space-small);
  border-top: 1px solid var(--color-border);
}
</style>
