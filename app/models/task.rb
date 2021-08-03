class Task < ApplicationRecord
  include ActiveRecord::AttributeAssignment
  attribute :deadline
end
