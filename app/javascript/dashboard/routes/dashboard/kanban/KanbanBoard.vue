<script setup>
import { ref, computed, onMounted } from 'vue';
import { useStore } from 'vuex';
import { useI18n } from 'vue-i18n';
import Button from 'dashboard/components-next/button/Button.vue';
import Dialog from 'dashboard/components-next/dialog/Dialog.vue';
import KanbanColumn from './components/KanbanColumn.vue';
import KanbanColumnForm from './components/KanbanColumnForm.vue';
import KanbanCardForm from './components/KanbanCardForm.vue';

const props = defineProps({
  pipelineId: { type: [Number, String], required: true },
});

const store = useStore();
const { t } = useI18n();

const columnDialogRef = ref(null);
const cardDialogRef = ref(null);
const editingColumn = ref(null);
const addingToColumnId = ref(null);

const activePipeline = computed(() => store.getters['kanban/getActivePipeline']);
const columns = computed(() => store.getters['kanban/getColumns']);
const uiFlags = computed(() => store.getters['kanban/getUIFlags']);

onMounted(() => {
  store.dispatch('kanban/fetchPipeline', props.pipelineId);
});

const openAddColumnModal = () => {
  editingColumn.value = null;
  columnDialogRef.value?.open();
};

const openEditColumnModal = column => {
  editingColumn.value = column;
  columnDialogRef.value?.open();
};

const closeColumnModal = () => {
  editingColumn.value = null;
  columnDialogRef.value?.close();
};

const openAddCardModal = columnId => {
  addingToColumnId.value = columnId;
  cardDialogRef.value?.open();
};

const closeCardModal = () => {
  addingToColumnId.value = null;
  cardDialogRef.value?.close();
};

const onCardDropped = ({ cardId, fromColumnId, toColumnId, position }) => {
  store.dispatch('kanban/moveCard', {
    pipelineId: props.pipelineId,
    cardId,
    fromColumnId,
    toColumnId,
    position,
  });
};

const onDeleteColumn = columnId => {
  store.dispatch('kanban/deleteColumn', {
    pipelineId: props.pipelineId,
    columnId,
  });
};
</script>

<template>
  <div class="flex flex-col h-full p-4 overflow-hidden">
    <!-- Header -->
    <div class="flex items-center justify-between mb-4 flex-shrink-0">
      <h2 class="text-base font-semibold text-n-slate-12 m-0">
        {{ activePipeline?.name || t('KANBAN.TITLE') }}
      </h2>
      <Button
        icon="i-lucide-plus"
        size="sm"
        variant="faded"
        color="blue"
        :label="t('KANBAN.ADD_COLUMN')"
        @click="openAddColumnModal"
      />
    </div>

    <!-- Loading -->
    <div v-if="uiFlags.isFetching" class="flex items-center justify-center flex-1 text-n-slate-11 text-sm">
      {{ t('KANBAN.LOADING') }}
    </div>

    <!-- Columns -->
    <div v-else class="flex gap-3 overflow-x-auto flex-1 pb-2">
      <KanbanColumn
        v-for="column in columns"
        :key="column.id"
        :column="column"
        :pipeline-id="pipelineId"
        @card-dropped="onCardDropped"
        @add-card="openAddCardModal"
        @delete-column="onDeleteColumn"
        @edit-column="openEditColumnModal"
      />

      <div
        v-if="!columns.length"
        class="flex items-center justify-center flex-1 text-n-slate-11 text-sm"
      >
        {{ t('KANBAN.EMPTY_COLUMNS') }}
      </div>
    </div>

    <!-- Column Dialog -->
    <Dialog
      ref="columnDialogRef"
      :title="editingColumn ? t('KANBAN.COLUMN_FORM.EDIT_TITLE') : t('KANBAN.COLUMN_FORM.TITLE')"
      :show-confirm-button="false"
      :show-cancel-button="false"
      width="sm"
      @close="closeColumnModal"
    >
      <KanbanColumnForm
        :column="editingColumn"
        :pipeline-id="pipelineId"
        @close="closeColumnModal"
      />
    </Dialog>

    <!-- Card Dialog -->
    <Dialog
      ref="cardDialogRef"
      :title="t('KANBAN.CARD_FORM.TITLE')"
      :show-confirm-button="false"
      :show-cancel-button="false"
      width="sm"
      @close="closeCardModal"
    >
      <KanbanCardForm
        v-if="addingToColumnId"
        :column-id="addingToColumnId"
        :pipeline-id="pipelineId"
        @close="closeCardModal"
      />
    </Dialog>
  </div>
</template>
