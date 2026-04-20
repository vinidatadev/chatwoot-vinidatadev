class AddKanbanEnhancements < ActiveRecord::Migration[7.0]
  def change
    # Pipeline: auto_add flag
    add_column :kanban_pipelines, :auto_add_conversations, :boolean, default: false, null: false

    # Column: entry_point flag + webhook_url
    add_column :kanban_columns, :is_entry_point, :boolean, default: false, null: false
    add_column :kanban_columns, :webhook_url, :string
  end
end
