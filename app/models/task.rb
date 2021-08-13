class Task < ApplicationRecord
  belongs_to :user
  with_options presence: true do
    validates :title
    validates :content
    validates :deadline
    validates :status
  end

  scope :incomplete, -> {
    where(status: ["未対応", "対応中"])
  }

  scope :index_myself, -> {
    where(status: "未対応").or(where(status: "対応中"))
    .where(user_id: current_user)
  }
end
