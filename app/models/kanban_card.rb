class KanbanCard < ApplicationRecord
  belongs_to :account
  belongs_to :kanban_pipeline
  belongs_to :kanban_column
  belongs_to :conversation

  validates :conversation_id, uniqueness: { scope: :kanban_pipeline_id }

  default_scope { order(:position) }

  before_create :set_entered_column_at
  before_update :reset_entered_column_at_on_column_change

  private

  def set_entered_column_at
    self.entered_column_at ||= Time.current
  end

  def reset_entered_column_at_on_column_change
    self.entered_column_at = Time.current if kanban_column_id_changed?
  end
end
