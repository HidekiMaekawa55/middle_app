class Task < ApplicationRecord
  include ActiveRecord::AttributeAssignment
  belongs_to :user
  attribute :deadline
  with_options presence: true do
    validates :title
    validates :content
    validates :deadline
    validates :status
  end

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
