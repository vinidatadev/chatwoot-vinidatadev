class CreateKanbanCards < ActiveRecord::Migration[7.0]
  def change
    create_table :kanban_cards do |t|
      t.integer :position, default: 0
      t.text :notes
      t.references :kanban_column, null: false, foreign_key: true
      t.references :kanban_pipeline, null: false, foreign_key: true
      t.references :conversation, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true

      t.timestamps
    end

    add_index :kanban_cards, [:kanban_column_id, :position]
    add_index :kanban_cards, [:conversation_id, :kanban_pipeline_id], unique: true
  end
end
