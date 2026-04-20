<template>
  <div
    class="kanban-card"
    @dragstart="$emit('dragstart', $event)"
  >
    <div class="card-header">
      <span class="card-id">#{{ conversation.display_id }}</span>
      <span class="card-status" :class="`status-${conversation.status}`">
        {{ conversation.status }}
      </span>
    </div>

    <p v-if="conversation.meta && conversation.meta.sender" class="card-contact">
      {{ conversation.meta.sender.name }}
    </p>

    <p v-if="card.notes" class="card-notes">{{ card.notes }}</p>

    <div class="card-footer">
      <woot-button
        size="tiny"
        variant="clear"
        color-scheme="alert"
        icon="delete"
        @click.stop="onDelete"
      />
    </div>
  </div>
</template>

<script>
import { mapActions } from 'vuex';

export default {
  name: 'KanbanCard',

  props: {
    card: { type: Object, required: true },
    pipelineId: { type: [Number, String], required: true },
    columnId: { type: [Number, String], required: true },
  },

  emits: ['dragstart'],

  computed: {
    conversation() {
      return this.card.conversation || {};
    },
  },

  methods: {
    ...mapActions({ deleteCard: 'kanban/deleteCard' }),

    async onDelete() {
      await this.deleteCard({
        pipelineId: this.pipelineId,
        cardId: this.card.id,
        columnId: this.columnId,
      });
    },
  },
};
</script>

<style lang="scss" scoped>
.kanban-card {
  background: var(--white);
  border-radius: var(--border-radius-normal);
  padding: var(--space-small);
  box-shadow: var(--shadow-small);
  cursor: grab;

  &:active {
    cursor: grabbing;
  }
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: var(--space-smaller);
}

.card-id {
  font-size: var(--font-size-mini);
  color: var(--color-body);
  font-weight: var(--font-weight-bold);
}

.card-status {
  font-size: var(--font-size-mini);
  padding: 1px 6px;
  border-radius: 10px;
  text-transform: capitalize;

  &.status-open { background: var(--g-50); color: var(--g-700); }
  &.status-resolved { background: var(--s-50); color: var(--s-700); }
  &.status-pending { background: var(--y-50); color: var(--y-700); }
  &.status-snoozed { background: var(--color-background); color: var(--color-body); }
}

.card-contact {
  font-size: var(--font-size-small);
  font-weight: var(--font-weight-medium);
  margin: 0 0 var(--space-smaller);
}

.card-notes {
  font-size: var(--font-size-mini);
  color: var(--color-body);
  margin: 0 0 var(--space-smaller);
}

.card-footer {
  display: flex;
  justify-content: flex-end;
}
</style>
