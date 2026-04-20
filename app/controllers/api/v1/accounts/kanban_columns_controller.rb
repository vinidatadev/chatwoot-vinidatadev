class Api::V1::Accounts::KanbanColumnsController < Api::V1::Accounts::BaseController
  before_action :fetch_pipeline
  before_action :fetch_column, except: [:index, :create]
  before_action :check_authorization

  def index
    @columns = @pipeline.kanban_columns
    render json: @columns
  end

  def create
    @column = @pipeline.kanban_columns.create!(column_params.merge(account: Current.account))
    render json: @column, status: :created
  end

  def update
    @column.update!(column_params)
    render json: @column
  end

  def destroy
    @column.destroy!
    head :ok
  end

  private

  def fetch_pipeline
    @pipeline = Current.account.kanban_pipelines.find(params[:kanban_pipeline_id])
  end

  def fetch_column
    @column = @pipeline.kanban_columns.find(params[:id])
  end

  def column_params
    params.require(:kanban_column).permit(:name, :position, :color)
  end
end
