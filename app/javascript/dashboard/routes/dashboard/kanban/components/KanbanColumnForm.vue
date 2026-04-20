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
const isEntryPoint = ref(props.column?.is_entry_point || false);
const webhookUrl = ref(props.column?.webhook_url || '');
const slaMinutes = ref(props.column?.sla_minutes || '');

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
        is_entry_point: isEntryPoint.value,
        webhook_url: webhookUrl.value,
        sla_minutes: slaMinutes.value || null,
      });
    } else {
      await store.dispatch('kanban/createColumn', {
        pipelineId: props.pipelineId,
        name: name.value,
        color: color.value,
        is_entry_point: isEntryPoint.value,
        webhook_url: webhookUrl.value,
        sla_minutes: slaMinutes.value || null,
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
      <label class="text-sm font-medium text-n-slate-12">{{ t('KANBAN.COLUMN_FORM.NAME') }}</label>
      <input
        v-model="name"
        type="text"
        :placeholder="t('KANBAN.COLUMN_FORM.NAME_PLACEHOLDER')"
        required
        class="h-9 px-3 text-sm rounded-lg border border-n-weak bg-n-background text-n-slate-12 outline-none focus:border-n-brand transition-colors"
      />
    </div>

    <div class="flex items-center gap-3">
      <label class="text-sm font-medium text-n-slate-12">{{ t('KANBAN.COLUMN_FORM.COLOR') }}</label>
      <input v-model="color" type="color" class="h-9 w-16 rounded-lg border border-n-weak cursor-pointer bg-n-background" />
      <span class="text-sm text-n-slate-11">{{ color }}</span>
    </div>

    <!-- Entry point toggle -->
    <label class="flex items-start gap-3 cursor-pointer">
      <div class="relative mt-0.5">
        <input v-model="isEntryPoint" type="checkbox" class="sr-only peer" />
        <div class="w-9 h-5 bg-n-alpha-3 rounded-full peer peer-checked:bg-n-brand transition-colors outline outline-1 outline-n-weak peer-checked:outline-n-brand" />
        <div class="absolute top-0.5 left-0.5 w-4 h-4 bg-white rounded-full shadow transition-transform peer-checked:translate-x-4" />
      </div>
      <div class="flex flex-col gap-0.5">
        <span class="text-sm font-medium text-n-slate-12">{{ t('KANBAN.COLUMN_FORM.ENTRY_POINT') }}</span>
        <span class="text-xs text-n-slate-11">{{ t('KANBAN.COLUMN_FORM.ENTRY_POINT_HINT') }}</span>
      </div>
    </label>

    <!-- Webhook URL -->
    <div class="flex flex-col gap-1">
      <label class="text-sm font-medium text-n-slate-12">{{ t('KANBAN.COLUMN_FORM.WEBHOOK_URL') }}</label>
      <input
        v-model="webhookUrl"
        type="url"
        :placeholder="t('KANBAN.COLUMN_FORM.WEBHOOK_URL_PLACEHOLDER')"
        class="h-9 px-3 text-sm rounded-lg border border-n-weak bg-n-background text-n-slate-12 outline-none focus:border-n-brand transition-colors"
      />
      <span class="text-xs text-n-slate-10">{{ t('KANBAN.COLUMN_FORM.WEBHOOK_URL_HINT') }}</span>
    </div>

    <!-- SLA / Timer -->
    <div class="flex flex-col gap-1">
      <label class="text-sm font-medium text-n-slate-12">{{ t('KANBAN.COLUMN_FORM.SLA_MINUTES') }}</label>
      <div class="flex items-center gap-2">
        <input
          v-model.number="slaMinutes"
          type="number"
          min="1"
          :placeholder="t('KANBAN.COLUMN_FORM.SLA_MINUTES_PLACEHOLDER')"
          class="h-9 w-28 px-3 text-sm rounded-lg border border-n-weak bg-n-background text-n-slate-12 outline-none focus:border-n-brand transition-colors"
        />
        <span class="text-sm text-n-slate-11">{{ t('KANBAN.COLUMN_FORM.SLA_MINUTES_UNIT') }}</span>
      </div>
      <span class="text-xs text-n-slate-10">{{ t('KANBAN.COLUMN_FORM.SLA_MINUTES_HINT') }}</span>
    </div>

    <div class="flex justify-end gap-2 pt-1">
      <Button type="button" variant="faded" color="slate" size="sm" :label="t('CANCEL')" @click="emit('close')" />
      <Button type="submit" size="sm" :label="column ? t('SAVE') : t('KANBAN.COLUMN_FORM.SUBMIT')" :is-loading="isLoading" />
    </div>
  </form>
</template>
