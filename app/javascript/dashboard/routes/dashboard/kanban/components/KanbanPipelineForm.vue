<template>
  <div class="kanban-form">
    <woot-modal-header :header-title="$t('KANBAN.PIPELINE_FORM.TITLE')" />
    <form @submit.prevent="onSubmit">
      <div class="form-body">
        <label>
          {{ $t('KANBAN.PIPELINE_FORM.NAME') }}
          <input
            v-model="form.name"
            type="text"
            :placeholder="$t('KANBAN.PIPELINE_FORM.NAME_PLACEHOLDER')"
            required
          />
        </label>
        <label>
          {{ $t('KANBAN.PIPELINE_FORM.DESCRIPTION') }}
          <textarea
            v-model="form.description"
            :placeholder="$t('KANBAN.PIPELINE_FORM.DESCRIPTION_PLACEHOLDER')"
            rows="3"
          />
        </label>
      </div>
      <div class="form-footer">
        <woot-button variant="clear" @click="$emit('close')">
          {{ $t('CANCEL') }}
        </woot-button>
        <woot-button type="submit" :loading="isLoading">
          {{ $t('KANBAN.PIPELINE_FORM.SUBMIT') }}
        </woot-button>
      </div>
    </form>
  </div>
</template>

<script>
import { mapActions } from 'vuex';

export default {
  name: 'KanbanPipelineForm',
  emits: ['close'],

  data() {
    return {
      isLoading: false,
      form: { name: '', description: '' },
    };
  },

  methods: {
    ...mapActions({ createPipeline: 'kanban/createPipeline' }),

    async onSubmit() {
      this.isLoading = true;
      try {
        await this.createPipeline(this.form);
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
