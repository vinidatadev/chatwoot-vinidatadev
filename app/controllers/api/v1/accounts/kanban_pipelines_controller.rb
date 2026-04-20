class Api::V1::Accounts::KanbanPipelinesController < Api::V1::Accounts::BaseController
  before_action :fetch_pipeline, except: [:index, :create]
  before_action :check_authorization

  def index
    @pipelines = Current.account.kanban_pipelines
    render json: @pipelines
  end

  def show
    render json: @pipeline.as_json(include: {
      kanban_columns: {
        include: {
          kanban_cards: {
            include: {
              conversation: {
                only: [:id, :display_id, :status, :inbox_id, :priority, :created_at, :last_activity_at],
                include: {
                  contact: { only: [:id, :name, :avatar_url, :phone_number] },
                  assignee: { only: [:id, :name, :avatar_url] },
                  inbox: { only: [:id, :name, :channel_type] }
                }
              }
            }
          }
        }
      }
    })
  end

  def create
    @pipeline = Current.account.kanban_pipelines.create!(pipeline_params)
    render json: @pipeline, status: :created
  end

  def update
    @pipeline.update!(pipeline_params)
    render json: @pipeline
  end

  def destroy
    @pipeline.destroy!
    head :ok
  end

  private

  def fetch_pipeline
    @pipeline = Current.account.kanban_pipelines.find(params[:id])
  end

  def pipeline_params
    params.require(:kanban_pipeline).permit(:name, :description, :position, :auto_add_conversations)
  end
end
