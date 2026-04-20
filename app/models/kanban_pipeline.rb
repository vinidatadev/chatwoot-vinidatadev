# == Schema Information
#
# Table name: kanban_pipelines
#
#  id          :bigint           not null, primary key
#  name        :string           not null
#  description :text
#  position    :integer          default(0)
#  account_id  :bigint           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class KanbanPipeline < ApplicationRecord
  belongs_to :account
  has_many :kanban_columns, dependent: :destroy
  has_many :kanban_cards, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :account_id }

  default_scope { order(:position, :name) }
end
