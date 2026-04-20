import KanbanAPI from '../../api/kanban';

const state = {
  pipelines: [],
  activePipeline: null,
  uiFlags: {
    isFetching: false,
    isCreating: false,
    isUpdating: false,
    isDeleting: false,
  },
};

const getters = {
  getPipelines: $state => $state.pipelines,
  getActivePipeline: $state => $state.activePipeline,
  getUIFlags: $state => $state.uiFlags,
  getColumns: $state =>
    $state.activePipeline ? $state.activePipeline.kanban_columns || [] : [],
};

const mutations = {
  SET_PIPELINES($state, pipelines) {
    $state.pipelines = pipelines;
  },
  SET_ACTIVE_PIPELINE($state, pipeline) {
    $state.activePipeline = pipeline;
  },
  ADD_PIPELINE($state, pipeline) {
    $state.pipelines.push(pipeline);
  },
  UPDATE_PIPELINE($state, pipeline) {
    const idx = $state.pipelines.findIndex(p => p.id === pipeline.id);
    if (idx !== -1) $state.pipelines.splice(idx, 1, pipeline);
    if ($state.activePipeline?.id === pipeline.id) {
      $state.activePipeline = { ...$state.activePipeline, ...pipeline };
    }
  },
  REMOVE_PIPELINE($state, pipelineId) {
    $state.pipelines = $state.pipelines.filter(p => p.id !== pipelineId);
    if ($state.activePipeline?.id === pipelineId) $state.activePipeline = null;
  },
  SET_UI_FLAG($state, flags) {
    $state.uiFlags = { ...$state.uiFlags, ...flags };
  },
  // Column mutations on activePipeline
  ADD_COLUMN($state, column) {
    if (!$state.activePipeline) return;
    $state.activePipeline = {
      ...$state.activePipeline,
      kanban_columns: [...($state.activePipeline.kanban_columns || []), column],
    };
  },
  UPDATE_COLUMN($state, column) {
    if (!$state.activePipeline) return;
    const cols = ($state.activePipeline.kanban_columns || []).map(c =>
      c.id === column.id ? column : c
    );
    $state.activePipeline = { ...$state.activePipeline, kanban_columns: cols };
  },
  REMOVE_COLUMN($state, columnId) {
    if (!$state.activePipeline) return;
    const cols = ($state.activePipeline.kanban_columns || []).filter(
      c => c.id !== columnId
    );
    $state.activePipeline = { ...$state.activePipeline, kanban_columns: cols };
  },
  // Card mutations
  ADD_CARD($state, card) {
    if (!$state.activePipeline) return;
    const cols = ($state.activePipeline.kanban_columns || []).map(col => {
      if (col.id !== card.kanban_column_id) return col;
      return {
        ...col,
        kanban_cards: [...(col.kanban_cards || []), card],
      };
    });
    $state.activePipeline = { ...$state.activePipeline, kanban_columns: cols };
  },
  UPDATE_CARD($state, card) {
    if (!$state.activePipeline) return;
    const cols = ($state.activePipeline.kanban_columns || []).map(col => {
      const cards = (col.kanban_cards || []).map(c =>
        c.id === card.id ? card : c
      );
      return { ...col, kanban_cards: cards };
    });
    $state.activePipeline = { ...$state.activePipeline, kanban_columns: cols };
  },
  MOVE_CARD($state, { cardId, fromColumnId, toColumnId, position }) {
    if (!$state.activePipeline) return;
    let movedCard = null;
    const cols = ($state.activePipeline.kanban_columns || []).map(col => {
      if (col.id === fromColumnId) {
        const cards = (col.kanban_cards || []).filter(c => {
          if (c.id === cardId) {
            movedCard = c;
            return false;
          }
          return true;
        });
        return { ...col, kanban_cards: cards };
      }
      return col;
    });
    if (!movedCard) return;
    movedCard = { ...movedCard, kanban_column_id: toColumnId, position };
    const finalCols = cols.map(col => {
      if (col.id !== toColumnId) return col;
      const cards = [...(col.kanban_cards || [])];
      cards.splice(position, 0, movedCard);
      return { ...col, kanban_cards: cards };
    });
    $state.activePipeline = {
      ...$state.activePipeline,
      kanban_columns: finalCols,
    };
  },
  REMOVE_CARD($state, { cardId, columnId }) {
    if (!$state.activePipeline) return;
    const cols = ($state.activePipeline.kanban_columns || []).map(col => {
      if (col.id !== columnId) return col;
      return {
        ...col,
        kanban_cards: (col.kanban_cards || []).filter(c => c.id !== cardId),
      };
    });
    $state.activePipeline = { ...$state.activePipeline, kanban_columns: cols };
  },
};

const actions = {
  async fetchPipelines({ commit }) {
    commit('SET_UI_FLAG', { isFetching: true });
    try {
      const { data } = await KanbanAPI.getPipelines();
      commit('SET_PIPELINES', data);
    } finally {
      commit('SET_UI_FLAG', { isFetching: false });
    }
  },

  async fetchPipeline({ commit }, pipelineId) {
    commit('SET_UI_FLAG', { isFetching: true });
    try {
      const { data } = await KanbanAPI.getPipeline(pipelineId);
      commit('SET_ACTIVE_PIPELINE', data);
    } finally {
      commit('SET_UI_FLAG', { isFetching: false });
    }
  },

  async createPipeline({ commit }, pipelineData) {
    commit('SET_UI_FLAG', { isCreating: true });
    try {
      const { data } = await KanbanAPI.createPipeline(pipelineData);
      commit('ADD_PIPELINE', data);
      return data;
    } finally {
      commit('SET_UI_FLAG', { isCreating: false });
    }
  },

  async updatePipeline({ commit }, { pipelineId, ...pipelineData }) {
    commit('SET_UI_FLAG', { isUpdating: true });
    try {
      const { data } = await KanbanAPI.updatePipeline(pipelineId, pipelineData);
      commit('UPDATE_PIPELINE', data);
      return data;
    } finally {
      commit('SET_UI_FLAG', { isUpdating: false });
    }
  },

  async deletePipeline({ commit }, pipelineId) {
    commit('SET_UI_FLAG', { isDeleting: true });
    try {
      await KanbanAPI.deletePipeline(pipelineId);
      commit('REMOVE_PIPELINE', pipelineId);
    } finally {
      commit('SET_UI_FLAG', { isDeleting: false });
    }
  },

  async createColumn({ commit }, { pipelineId, ...columnData }) {
    const { data } = await KanbanAPI.createColumn(pipelineId, columnData);
    commit('ADD_COLUMN', data);
    return data;
  },

  async updateColumn({ commit }, { pipelineId, columnId, ...columnData }) {
    const { data } = await KanbanAPI.updateColumn(
      pipelineId,
      columnId,
      columnData
    );
    commit('UPDATE_COLUMN', data);
    return data;
  },

  async deleteColumn({ commit }, { pipelineId, columnId }) {
    await KanbanAPI.deleteColumn(pipelineId, columnId);
    commit('REMOVE_COLUMN', columnId);
  },

  async createCard({ commit }, { pipelineId, ...cardData }) {
    const { data } = await KanbanAPI.createCard(pipelineId, cardData);
    commit('ADD_CARD', data);
    return data;
  },

  async updateCard({ commit }, { pipelineId, cardId, ...cardData }) {
    const { data } = await KanbanAPI.updateCard(pipelineId, cardId, cardData);
    commit('UPDATE_CARD', data);
    return data;
  },

  async moveCard({ commit }, { pipelineId, cardId, fromColumnId, toColumnId, position }) {
    commit('MOVE_CARD', { cardId, fromColumnId, toColumnId, position });
    try {
      await KanbanAPI.updateCard(pipelineId, cardId, {
        kanban_column_id: toColumnId,
        position,
      });
    } catch {
      // revert on failure by re-fetching
      commit('MOVE_CARD', {
        cardId,
        fromColumnId: toColumnId,
        toColumnId: fromColumnId,
        position,
      });
    }
  },

  async deleteCard({ commit }, { pipelineId, cardId, columnId }) {
    await KanbanAPI.deleteCard(pipelineId, cardId);
    commit('REMOVE_CARD', { cardId, columnId });
  },
};

export default {
  namespaced: true,
  state,
  getters,
  mutations,
  actions,
};
