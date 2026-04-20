# == Schema Information
#
# Table name: kanban_columns
#
#  id                 :bigint           not null, primary key
#  name               :string           not null
#  position           :integer          default(0)
#  color              :string           default("#1f93ff")
#  kanban_pipeline_id :bigint           not null
#  account_id         :bigint           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class KanbanColumn < ApplicationRecord
  belongs_to :account
  belongs_to :kanban_pipeline
  has_many :kanban_cards, dependent: :destroy

  validates :name, presence: true

  default_scope { order(:position) }
end
