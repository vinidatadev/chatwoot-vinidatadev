<template>
  <div class="kanban-index">
    <!-- Sidebar de pipelines -->
    <div class="kanban-sidebar">
      <div class="kanban-sidebar-header">
        <span class="sidebar-title">{{ $t('KANBAN.PIPELINES') }}</span>
        <woot-button
          size="tiny"
          variant="clear"
          icon="add"
          @click="openCreatePipelineModal"
        />
      </div>

      <div v-if="uiFlags.isFetching" class="sidebar-loading">...</div>

      <ul v-else class="pipeline-list">
        <li
          v-for="pipeline in pipelines"
          :key="pipeline.id"
          class="pipeline-item"
          :class="{ active: activePipelineId === pipeline.id }"
          @click="selectPipeline(pipeline.id)"
        >
          <span class="pipeline-name">{{ pipeline.name }}</span>
          <woot-button
            size="tiny"
            variant="clear"
            icon="delete"
            color-scheme="alert"
            @click.stop="onDeletePipeline(pipeline.id)"
          />
        </li>
      </ul>
    </div>

    <!-- Board -->
    <div class="kanban-content">
      <kanban-board
        v-if="activePipelineId"
        :pipeline-id="activePipelineId"
      />
      <div v-else class="kanban-no-pipeline">
        <p>{{ $t('KANBAN.SELECT_PIPELINE') }}</p>
      </div>
    </div>

    <!-- Create Pipeline Modal -->
    <woot-modal :show.sync="showPipelineModal" :on-close="closePipelineModal">
      <kanban-pipeline-form @close="closePipelineModal" />
    </woot-modal>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex';
import KanbanBoard from './KanbanBoard.vue';
import KanbanPipelineForm from './components/KanbanPipelineForm.vue';

export default {
  name: 'KanbanIndex',
  components: { KanbanBoard, KanbanPipelineForm },

  data() {
    return {
      activePipelineId: null,
      showPipelineModal: false,
    };
  },

  computed: {
    ...mapGetters({
      pipelines: 'kanban/getPipelines',
      uiFlags: 'kanban/getUIFlags',
    }),
  },

  mounted() {
    this.fetchPipelines().then(() => {
      if (this.pipelines.length) {
        this.activePipelineId = this.pipelines[0].id;
      }
    });
  },

  methods: {
    ...mapActions({
      fetchPipelines: 'kanban/fetchPipelines',
      deletePipeline: 'kanban/deletePipeline',
    }),

    selectPipeline(id) {
      this.activePipelineId = id;
    },

    openCreatePipelineModal() {
      this.showPipelineModal = true;
    },

    closePipelineModal() {
      this.showPipelineModal = false;
    },

    async onDeletePipeline(id) {
      await this.deletePipeline(id);
      if (this.activePipelineId === id) {
        this.activePipelineId = this.pipelines[0]?.id || null;
      }
    },
  },
};
</script>

<style lang="scss" scoped>
.kanban-index {
  display: flex;
  height: 100%;
  overflow: hidden;
}

.kanban-sidebar {
  width: 220px;
  min-width: 220px;
  border-right: 1px solid var(--color-border);
  padding: var(--space-normal);
  overflow-y: auto;
}

.kanban-sidebar-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: var(--space-small);
}

.sidebar-title {
  font-weight: var(--font-weight-bold);
  font-size: var(--font-size-small);
  text-transform: uppercase;
  color: var(--color-body);
}

.pipeline-list {
  list-style: none;
  margin: 0;
  padding: 0;
}

.pipeline-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: var(--space-small);
  border-radius: var(--border-radius-normal);
  cursor: pointer;

  &:hover {
    background: var(--color-background-light);
  }

  &.active {
    background: var(--color-woot-25);
    color: var(--color-woot);
  }
}

.pipeline-name {
  font-size: var(--font-size-small);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.kanban-content {
  flex: 1;
  overflow: hidden;
}

.kanban-no-pipeline {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
  color: var(--color-body);
}
</style>
