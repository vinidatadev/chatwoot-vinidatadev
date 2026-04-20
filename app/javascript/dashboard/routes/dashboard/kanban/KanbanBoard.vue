<template>
  <div class="kanban-board">
    <div class="kanban-header">
      <h2 class="kanban-title">{{ activePipeline ? activePipeline.name : $t('KANBAN.TITLE') }}</h2>
      <div class="kanban-actions">
        <woot-button
          size="small"
          icon="add"
          @click="openAddColumnModal"
        >
          {{ $t('KANBAN.ADD_COLUMN') }}
        </woot-button>
      </div>
    </div>

    <div v-if="uiFlags.isFetching" class="kanban-loading">
      <span>{{ $t('KANBAN.LOADING') }}</span>
    </div>

    <div v-else class="kanban-columns" @dragover.prevent>
      <kanban-column
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
        class="kanban-empty"
      >
        <p>{{ $t('KANBAN.EMPTY_COLUMNS') }}</p>
      </div>
    </div>

    <!-- Add/Edit Column Modal -->
    <woot-modal :show.sync="showColumnModal" :on-close="closeColumnModal">
      <kanban-column-form
        :column="editingColumn"
        :pipeline-id="pipelineId"
        @close="closeColumnModal"
      />
    </woot-modal>

    <!-- Add Card Modal -->
    <woot-modal :show.sync="showCardModal" :on-close="closeCardModal">
      <kanban-card-form
        :column-id="addingToColumnId"
        :pipeline-id="pipelineId"
        @close="closeCardModal"
      />
    </woot-modal>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex';
import KanbanColumn from './components/KanbanColumn.vue';
import KanbanColumnForm from './components/KanbanColumnForm.vue';
import KanbanCardForm from './components/KanbanCardForm.vue';

export default {
  name: 'KanbanBoard',
  components: { KanbanColumn, KanbanColumnForm, KanbanCardForm },

  props: {
    pipelineId: {
      type: [Number, String],
      required: true,
    },
  },

  data() {
    return {
      showColumnModal: false,
      showCardModal: false,
      editingColumn: null,
      addingToColumnId: null,
    };
  },

  computed: {
    ...mapGetters({
      activePipeline: 'kanban/getActivePipeline',
      columns: 'kanban/getColumns',
      uiFlags: 'kanban/getUIFlags',
    }),
  },

  mounted() {
    this.fetchPipeline(this.pipelineId);
  },

  methods: {
    ...mapActions({
      fetchPipeline: 'kanban/fetchPipeline',
      moveCard: 'kanban/moveCard',
      deleteColumn: 'kanban/deleteColumn',
    }),

    openAddColumnModal() {
      this.editingColumn = null;
      this.showColumnModal = true;
    },

    openEditColumnModal(column) {
      this.editingColumn = column;
      this.showColumnModal = true;
    },

    closeColumnModal() {
      this.showColumnModal = false;
      this.editingColumn = null;
    },

    openAddCardModal(columnId) {
      this.addingToColumnId = columnId;
      this.showCardModal = true;
    },

    closeCardModal() {
      this.showCardModal = false;
      this.addingToColumnId = null;
    },

    async onCardDropped({ cardId, fromColumnId, toColumnId, position }) {
      await this.moveCard({
        pipelineId: this.pipelineId,
        cardId,
        fromColumnId,
        toColumnId,
        position,
      });
    },

    async onDeleteColumn(columnId) {
      await this.deleteColumn({
        pipelineId: this.pipelineId,
        columnId,
      });
    },
  },
};
</script>

<style lang="scss" scoped>
.kanban-board {
  display: flex;
  flex-direction: column;
  height: 100%;
  padding: var(--space-normal);
  overflow: hidden;
}

.kanban-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: var(--space-normal);
}

.kanban-title {
  font-size: var(--font-size-large);
  font-weight: var(--font-weight-bold);
  color: var(--color-heading);
  margin: 0;
}

.kanban-columns {
  display: flex;
  gap: var(--space-normal);
  overflow-x: auto;
  flex: 1;
  padding-bottom: var(--space-normal);
}

.kanban-loading,
.kanban-empty {
  display: flex;
  align-items: center;
  justify-content: center;
  flex: 1;
  color: var(--color-body);
}
</style>
