<script setup>
import { ref } from 'vue';
import { useStore } from 'vuex';
import { useI18n } from 'vue-i18n';
import Button from 'dashboard/components-next/button/Button.vue';

const emit = defineEmits(['close', 'created']);

const store = useStore();
const { t } = useI18n();

const isLoading = ref(false);
const name = ref('');
const description = ref('');

const onSubmit = async () => {
  if (!name.value.trim()) return;
  isLoading.value = true;
  try {
    await store.dispatch('kanban/createPipeline', {
      name: name.value,
      description: description.value,
    });
    emit('created');
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
        {{ t('KANBAN.PIPELINE_FORM.NAME') }}
      </label>
      <input
        v-model="name"
        type="text"
        :placeholder="t('KANBAN.PIPELINE_FORM.NAME_PLACEHOLDER')"
        required
        class="h-9 px-3 text-sm rounded-lg border border-n-weak bg-n-background text-n-slate-12 outline-none focus:border-n-brand transition-colors"
      />
    </div>

    <div class="flex flex-col gap-1">
      <label class="text-sm font-medium text-n-slate-12">
        {{ t('KANBAN.PIPELINE_FORM.DESCRIPTION') }}
      </label>
      <textarea
        v-model="description"
        :placeholder="t('KANBAN.PIPELINE_FORM.DESCRIPTION_PLACEHOLDER')"
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
        :label="t('KANBAN.PIPELINE_FORM.SUBMIT')"
        :is-loading="isLoading"
      />
    </div>
  </form>
</template>
