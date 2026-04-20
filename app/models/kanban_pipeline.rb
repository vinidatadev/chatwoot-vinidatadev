class KanbanPipeline < ApplicationRecord
  belongs_to :account
  has_many :kanban_columns, dependent: :destroy
  has_many :kanban_cards, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :account_id }

  default_scope { order(:position, :name) }

  def entry_column
    kanban_columns.find_by(is_entry_point: true) || kanban_columns.first
  end
end
