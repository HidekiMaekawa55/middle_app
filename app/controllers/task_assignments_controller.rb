class TaskAssignmentsController < ApplicationController

  def edit
  end

  def update
  end

  private
    def set_task
      @task = Task.find()
    end
end
