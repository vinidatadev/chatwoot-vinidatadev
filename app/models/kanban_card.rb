# == Schema Information
#
# Table name: kanban_cards
#
#  id                 :bigint           not null, primary key
#  position           :integer          default(0)
#  notes              :text
#  kanban_column_id   :bigint           not null
#  kanban_pipeline_id :bigint           not null
#  conversation_id    :bigint           not null
#  account_id         :bigint           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class KanbanCard < ApplicationRecord
  belongs_to :account
  belongs_to :kanban_pipeline
  belongs_to :kanban_column
  belongs_to :conversation

  validates :conversation_id, uniqueness: { scope: :kanban_pipeline_id }

  default_scope { order(:position) }
end
