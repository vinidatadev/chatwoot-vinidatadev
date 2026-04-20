import ApiClient from './ApiClient';

class KanbanAPI extends ApiClient {
  constructor() {
    super('kanban_pipelines', { accountScoped: true });
  }

  // Pipelines
  getPipelines() {
    return axios.get(this.url);
  }

  getPipeline(pipelineId) {
    return axios.get(`${this.url}/${pipelineId}`);
  }

  createPipeline(data) {
    return axios.post(this.url, { kanban_pipeline: data });
  }

  updatePipeline(pipelineId, data) {
    return axios.patch(`${this.url}/${pipelineId}`, { kanban_pipeline: data });
  }

  deletePipeline(pipelineId) {
    return axios.delete(`${this.url}/${pipelineId}`);
  }

  // Columns
  getColumns(pipelineId) {
    return axios.get(`${this.url}/${pipelineId}/kanban_columns`);
  }

  createColumn(pipelineId, data) {
    return axios.post(`${this.url}/${pipelineId}/kanban_columns`, {
      kanban_column: data,
    });
  }

  updateColumn(pipelineId, columnId, data) {
    return axios.patch(
      `${this.url}/${pipelineId}/kanban_columns/${columnId}`,
      { kanban_column: data }
    );
  }

  deleteColumn(pipelineId, columnId) {
    return axios.delete(
      `${this.url}/${pipelineId}/kanban_columns/${columnId}`
    );
  }

  // Cards
  getCards(pipelineId) {
    return axios.get(`${this.url}/${pipelineId}/kanban_cards`);
  }

  createCard(pipelineId, data) {
    return axios.post(`${this.url}/${pipelineId}/kanban_cards`, {
      kanban_card: data,
    });
  }

  updateCard(pipelineId, cardId, data) {
    return axios.patch(`${this.url}/${pipelineId}/kanban_cards/${cardId}`, {
      kanban_card: data,
    });
  }

  deleteCard(pipelineId, cardId) {
    return axios.delete(`${this.url}/${pipelineId}/kanban_cards/${cardId}`);
  }
}

export default new KanbanAPI();
