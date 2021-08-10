class Task < ApplicationRecord
  include ActiveRecord::AttributeAssignment
  belongs_to :user
  attribute :deadline
  validates :title, presence: true
  validates :content, presence: true
  validates :deadline, presence: true
  validates :status, presence: true

  scope :index_all, -> {
    select(:id, :title, :content, :deadline, :status, :user_id)
    .where(status: "未対応").or(where(status: "対応中"))
    .includes(:user) 
  }

  scope :index_myself, -> (current_user) {
    select(:id, :title, :content, :deadline, :status, :user_id)
    .where(status: "未対応").or(where(status: "対応中"))
    .where(user_id: current_user)
    .includes(:user) 
  }
end
