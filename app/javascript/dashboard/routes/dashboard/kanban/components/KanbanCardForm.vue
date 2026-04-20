<script setup>
import { ref } from 'vue';
import { useStore } from 'vuex';
import { useI18n } from 'vue-i18n';
import Button from 'dashboard/components-next/button/Button.vue';

const props = defineProps({
  columnId: { type: [Number, String], required: true },
  pipelineId: { type: [Number, String], required: true },
});

const emit = defineEmits(['close']);

const store = useStore();
const { t } = useI18n();

const isLoading = ref(false);
const conversationId = ref(null);
const notes = ref('');

const onSubmit = async () => {
  if (!conversationId.value) return;
  isLoading.value = true;
  try {
    await store.dispatch('kanban/createCard', {
      pipelineId: props.pipelineId,
      kanban_column_id: props.columnId,
      conversation_id: conversationId.value,
      notes: notes.value,
    });
    emit('close');
  } finally {
    isLoading.value = false;
  }
};
</script>

<template>
  <form class="flex flex-col gap-4" @submit.prevent="onSubmit">
    <div class="flex flex-col gap-1">
      <label class="text-sm font-medium text-n-slate-12">
        {{ t('KANBAN.CARD_FORM.CONVERSATION_ID') }}
      </label>
      <input
        v-model.number="conversationId"
        type="number"
        :placeholder="t('KANBAN.CARD_FORM.CONVERSATION_ID_PLACEHOLDER')"
        required
        min="1"
        class="h-9 px-3 text-sm rounded-lg border border-n-weak bg-n-background text-n-slate-12 outline-none focus:border-n-brand transition-colors"
      />
    </div>

    <div class="flex flex-col gap-1">
      <label class="text-sm font-medium text-n-slate-12">
        {{ t('KANBAN.CARD_FORM.NOTES') }}
      </label>
      <textarea
        v-model="notes"
        :placeholder="t('KANBAN.CARD_FORM.NOTES_PLACEHOLDER')"
        rows="3"
        class="px-3 py-2 text-sm rounded-lg border border-n-weak bg-n-background text-n-slate-12 outline-none focus:border-n-brand transition-colors resize-none"
      />
    </div>

    <div class="flex justify-end gap-2 pt-1">
      <Button
        type="button"
        variant="faded"
        color="slate"
        size="sm"
        :label="t('CANCEL')"
        @click="emit('close')"
      />
      <Button
        type="submit"
        size="sm"
        :label="t('KANBAN.CARD_FORM.SUBMIT')"
        :is-loading="isLoading"
      />
    </div>
  </form>
</template>
