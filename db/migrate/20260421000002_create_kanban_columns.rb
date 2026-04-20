class CreateKanbanColumns < ActiveRecord::Migration[7.0]
  def change
    create_table :kanban_columns do |t|
      t.string :name, null: false
      t.integer :position, default: 0
      t.string :color, default: '#1f93ff'
      t.references :kanban_pipeline, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true

      t.timestamps
    end

    add_index :kanban_columns, [:kanban_pipeline_id, :position]
  end
end
