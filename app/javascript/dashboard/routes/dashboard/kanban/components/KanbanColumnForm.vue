<script setup>
import { ref } from 'vue';
import { useStore } from 'vuex';
import { useI18n } from 'vue-i18n';
import Button from 'dashboard/components-next/button/Button.vue';

const props = defineProps({
  column: { type: Object, default: null },
  pipelineId: { type: [Number, String], required: true },
});

const emit = defineEmits(['close']);

const store = useStore();
const { t } = useI18n();

const isLoading = ref(false);
const name = ref(props.column?.name || '');
const color = ref(props.column?.color || '#1f93ff');

const onSubmit = async () => {
  if (!name.value.trim()) return;
  isLoading.value = true;
  try {
    if (props.column) {
      await store.dispatch('kanban/updateColumn', {
        pipelineId: props.pipelineId,
        columnId: props.column.id,
        name: name.value,
        color: color.value,
      });
    } else {
      await store.dispatch('kanban/createColumn', {
        pipelineId: props.pipelineId,
        name: name.value,
        color: color.value,
      });
    }
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
        {{ t('KANBAN.COLUMN_FORM.NAME') }}
      </label>
      <input
        v-model="name"
        type="text"
        :placeholder="t('KANBAN.COLUMN_FORM.NAME_PLACEHOLDER')"
        required
        class="h-9 px-3 text-sm rounded-lg border border-n-weak bg-n-background text-n-slate-12 outline-none focus:border-n-brand transition-colors"
      />
    </div>

    <div class="flex items-center gap-3">
      <label class="text-sm font-medium text-n-slate-12">
        {{ t('KANBAN.COLUMN_FORM.COLOR') }}
      </label>
      <input
        v-model="color"
        type="color"
        class="h-9 w-16 rounded-lg border border-n-weak cursor-pointer bg-n-background"
      />
      <span class="text-sm text-n-slate-11">{{ color }}</span>
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
        :label="column ? t('SAVE') : t('KANBAN.COLUMN_FORM.SUBMIT')"
        :is-loading="isLoading"
      />
    </div>
  </form>
</template>
