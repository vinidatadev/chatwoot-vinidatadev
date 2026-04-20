class KanbanColumn < ApplicationRecord
  belongs_to :account
  belongs_to :kanban_pipeline
  has_many :kanban_cards, dependent: :destroy

  validates :name, presence: true

  default_scope { order(:position) }

  # Ensure only one entry_point per pipeline
  validate :single_entry_point_per_pipeline, if: :is_entry_point?

  private

  def single_entry_point_per_pipeline
    existing = kanban_pipeline.kanban_columns.where(is_entry_point: true).where.not(id: id)
    errors.add(:is_entry_point, 'already set on another column') if existing.exists?
  end
end
