<template>
  <div class="kanban-form">
    <woot-modal-header :header-title="$t('KANBAN.CARD_FORM.TITLE')" />
    <form @submit.prevent="onSubmit">
      <div class="form-body">
        <label>
          {{ $t('KANBAN.CARD_FORM.CONVERSATION_ID') }}
          <input
            v-model.number="form.conversation_id"
            type="number"
            :placeholder="$t('KANBAN.CARD_FORM.CONVERSATION_ID_PLACEHOLDER')"
            required
          />
        </label>
        <label>
          {{ $t('KANBAN.CARD_FORM.NOTES') }}
          <textarea
            v-model="form.notes"
            :placeholder="$t('KANBAN.CARD_FORM.NOTES_PLACEHOLDER')"
            rows="3"
          />
        </label>
      </div>
      <div class="form-footer">
        <woot-button variant="clear" @click="$emit('close')">
          {{ $t('CANCEL') }}
        </woot-button>
        <woot-button type="submit" :loading="isLoading">
          {{ $t('KANBAN.CARD_FORM.SUBMIT') }}
        </woot-button>
      </div>
    </form>
  </div>
</template>

<script>
import { mapActions } from 'vuex';

export default {
  name: 'KanbanCardForm',
  emits: ['close'],

  props: {
    columnId: { type: [Number, String], required: true },
    pipelineId: { type: [Number, String], required: true },
  },

  data() {
    return {
      isLoading: false,
      form: { conversation_id: null, notes: '' },
    };
  },

  methods: {
    ...mapActions({ createCard: 'kanban/createCard' }),

    async onSubmit() {
      this.isLoading = true;
      try {
        await this.createCard({
          pipelineId: this.pipelineId,
          kanban_column_id: this.columnId,
          ...this.form,
        });
        this.$emit('close');
      } finally {
        this.isLoading = false;
      }
    },
  },
};
</script>

<style lang="scss" scoped>
.kanban-form {
  padding: var(--space-normal);
  min-width: 400px;
}

.form-body {
  display: flex;
  flex-direction: column;
  gap: var(--space-normal);
  margin: var(--space-normal) 0;

  label {
    display: flex;
    flex-direction: column;
    gap: var(--space-smaller);
    font-size: var(--font-size-small);
    font-weight: var(--font-weight-medium);
  }

  input, textarea {
    border: 1px solid var(--color-border);
    border-radius: var(--border-radius-normal);
    padding: var(--space-small);
    font-size: var(--font-size-small);
  }
}

.form-footer {
  display: flex;
  justify-content: flex-end;
  gap: var(--space-small);
}
</style>
