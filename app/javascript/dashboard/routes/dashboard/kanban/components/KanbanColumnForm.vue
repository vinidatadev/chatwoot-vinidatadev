<template>
  <div class="kanban-form">
    <woot-modal-header
      :header-title="column ? $t('KANBAN.COLUMN_FORM.EDIT_TITLE') : $t('KANBAN.COLUMN_FORM.TITLE')"
    />
    <form @submit.prevent="onSubmit">
      <div class="form-body">
        <label>
          {{ $t('KANBAN.COLUMN_FORM.NAME') }}
          <input
            v-model="form.name"
            type="text"
            :placeholder="$t('KANBAN.COLUMN_FORM.NAME_PLACEHOLDER')"
            required
          />
        </label>
        <label>
          {{ $t('KANBAN.COLUMN_FORM.COLOR') }}
          <input v-model="form.color" type="color" />
        </label>
      </div>
      <div class="form-footer">
        <woot-button variant="clear" @click="$emit('close')">
          {{ $t('CANCEL') }}
        </woot-button>
        <woot-button type="submit" :loading="isLoading">
          {{ column ? $t('SAVE') : $t('KANBAN.COLUMN_FORM.SUBMIT') }}
        </woot-button>
      </div>
    </form>
  </div>
</template>

<script>
import { mapActions } from 'vuex';

export default {
  name: 'KanbanColumnForm',
  emits: ['close'],

  props: {
    column: { type: Object, default: null },
    pipelineId: { type: [Number, String], required: true },
  },

  data() {
    return {
      isLoading: false,
      form: {
        name: this.column?.name || '',
        color: this.column?.color || '#1f93ff',
      },
    };
  },

  methods: {
    ...mapActions({
      createColumn: 'kanban/createColumn',
      updateColumn: 'kanban/updateColumn',
    }),

    async onSubmit() {
      this.isLoading = true;
      try {
        if (this.column) {
          await this.updateColumn({
            pipelineId: this.pipelineId,
            columnId: this.column.id,
            ...this.form,
          });
        } else {
          await this.createColumn({
            pipelineId: this.pipelineId,
            ...this.form,
          });
        }
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
  min-width: 360px;
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

  input {
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
