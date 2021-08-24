class AddIndexToTasksDeadline < ActiveRecord::Migration[6.1]
  def change
    add_index :tasks, :deadline
    add_index :tasks, :created_at
  end
end
