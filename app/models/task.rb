class Task < ApplicationRecord
  belongs_to :user
  with_options presence: true do
    validates :title
    validates :content
    validates :deadline
    validates :status
  end

  scope :incomplete, -> (keyword) {
    where(status: ["未対応", "対応中"])
    .order(keyword)
  }
end
