<script setup>
import { ref, computed, onMounted } from 'vue';
import { useStore } from 'vuex';
import { useI18n } from 'vue-i18n';
import Button from 'dashboard/components-next/button/Button.vue';
import Dialog from 'dashboard/components-next/dialog/Dialog.vue';
import KanbanBoard from './KanbanBoard.vue';
import KanbanPipelineForm from './components/KanbanPipelineForm.vue';

const store = useStore();
const { t } = useI18n();

const activePipelineId = ref(null);
const showPipelineModal = ref(false);
const dialogRef = ref(null);
const pipelineFormRef = ref(null);

const pipelines = computed(() => store.getters['kanban/getPipelines']);
const uiFlags = computed(() => store.getters['kanban/getUIFlags']);

onMounted(async () => {
  await store.dispatch('kanban/fetchPipelines');
  if (pipelines.value.length) {
    activePipelineId.value = pipelines.value[0].id;
  }
});

const selectPipeline = id => {
  activePipelineId.value = id;
};

const openCreatePipelineModal = () => {
  showPipelineModal.value = true;
  dialogRef.value?.open();
};

const closePipelineModal = () => {
  showPipelineModal.value = false;
  dialogRef.value?.close();
};

const onDeletePipeline = async id => {
  await store.dispatch('kanban/deletePipeline', id);
  if (activePipelineId.value === id) {
    activePipelineId.value = pipelines.value[0]?.id || null;
  }
};

const onPipelineCreated = () => {
  closePipelineModal();
  if (!activePipelineId.value && pipelines.value.length) {
    activePipelineId.value = pipelines.value[0].id;
  }
};
</script>

<template>
  <div class="flex h-full overflow-hidden">
    <!-- Sidebar de pipelines -->
    <div class="flex flex-col w-56 min-w-[14rem] border-r border-n-weak overflow-y-auto p-3 gap-2">
      <div class="flex items-center justify-between mb-1">
        <span class="text-xs font-semibold uppercase text-n-slate-11 tracking-wide">
          {{ t('KANBAN.PIPELINES') }}
        </span>
        <Button
          icon="i-lucide-plus"
          size="xs"
          variant="ghost"
          color="slate"
          :title="t('KANBAN.PIPELINE_FORM.TITLE')"
          @click="openCreatePipelineModal"
        />
      </div>

      <div v-if="uiFlags.isFetching" class="text-sm text-n-slate-11 px-2">
        {{ t('KANBAN.LOADING') }}
      </div>

      <ul v-else class="flex flex-col gap-1 list-none m-0 p-0">
        <li
          v-for="pipeline in pipelines"
          :key="pipeline.id"
          class="flex items-center justify-between px-2 py-1.5 rounded-lg cursor-pointer group"
          :class="activePipelineId === pipeline.id
            ? 'bg-n-brand/10 text-n-blue-11'
            : 'hover:bg-n-alpha-2 text-n-slate-12'"
          @click="selectPipeline(pipeline.id)"
        >
          <span class="text-sm truncate flex-1">{{ pipeline.name }}</span>
          <Button
            icon="i-lucide-trash-2"
            size="xs"
            variant="ghost"
            color="ruby"
            class="opacity-0 group-hover:opacity-100"
            @click.stop="onDeletePipeline(pipeline.id)"
          />
        </li>

        <li v-if="!pipelines.length" class="text-xs text-n-slate-10 px-2 py-1">
          {{ t('KANBAN.NO_PIPELINES') }}
        </li>
      </ul>
    </div>

    <!-- Board -->
    <div class="flex-1 overflow-hidden">
      <KanbanBoard
        v-if="activePipelineId"
        :pipeline-id="activePipelineId"
      />
      <div v-else class="flex items-center justify-center h-full text-n-slate-11 text-sm">
        {{ t('KANBAN.SELECT_PIPELINE') }}
      </div>
    </div>

    <!-- Create Pipeline Dialog -->
    <Dialog
      ref="dialogRef"
      :title="t('KANBAN.PIPELINE_FORM.TITLE')"
      :show-confirm-button="false"
      :show-cancel-button="false"
      width="md"
      @close="closePipelineModal"
    >
      <KanbanPipelineForm
        ref="pipelineFormRef"
        @close="closePipelineModal"
        @created="onPipelineCreated"
      />
    </Dialog>
  </div>
</template>
