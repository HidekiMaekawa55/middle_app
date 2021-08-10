class User < ApplicationRecord
  has_many :tasks
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :timeoutable

  scope :user_all, -> {
    select(:id, :name)
  }
end
