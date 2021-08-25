class Task < ApplicationRecord
  belongs_to :user
  with_options presence: true do
    validates :title
    validates :content
    validates :deadline
    validates :status
  end

  scope :incomplete, -> (status) {
    where(status: status || ["未対応", "対応中"])
  }

  scope :order_by_keyword, -> (keyword) {
    return unless column_names.include?(keyword.to_s.split[0])
    order(keyword)
  }
end
