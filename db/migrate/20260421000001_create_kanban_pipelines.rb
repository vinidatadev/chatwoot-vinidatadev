class CreateKanbanPipelines < ActiveRecord::Migration[7.0]
  def change
    create_table :kanban_pipelines do |t|
      t.string :name, null: false
      t.text :description
      t.integer :position, default: 0
      t.references :account, null: false, foreign_key: true

      t.timestamps
    end

    add_index :kanban_pipelines, [:account_id, :name], unique: true
  end
end
