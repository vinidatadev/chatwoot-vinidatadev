class AddKanbanSlaAndTimer < ActiveRecord::Migration[7.0]
  def change
    # How many minutes a card can stay in this column before turning yellow/red
    add_column :kanban_columns, :sla_minutes, :integer

    # When the card entered the current column (reset on every move)
    add_column :kanban_cards, :entered_column_at, :datetime
  end
end
