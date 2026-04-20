class Api::V1::Accounts::KanbanCardsController < Api::V1::Accounts::BaseController
  before_action :fetch_pipeline
  before_action :fetch_card, except: [:index, :create]
  before_action :check_authorization

  def index
    @cards = @pipeline.kanban_cards.includes(:conversation, :kanban_column)
    render json: @cards.as_json(include: {
      conversation: { only: [:id, :display_id, :status, :inbox_id, :meta] }
    })
  end

  def create
    @card = @pipeline.kanban_cards.create!(card_params.merge(account: Current.account))
    render json: @card, status: :created
  end

  def update
    @card.update!(card_params)
    render json: @card
  end

  def destroy
    @card.destroy!
    head :ok
  end

  private

  def fetch_pipeline
    @pipeline = Current.account.kanban_pipelines.find(params[:kanban_pipeline_id])
  end

  def fetch_card
    @card = @pipeline.kanban_cards.find(params[:id])
  end

  def card_params
    params.require(:kanban_card).permit(:kanban_column_id, :conversation_id, :position, :notes)
  end
end
