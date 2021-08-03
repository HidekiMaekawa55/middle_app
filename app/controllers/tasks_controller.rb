class TasksController < ApplicationController
  def index
  end

  def show
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.create(task_params)
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private
    def task_params
      params.require(:task).permit(:title, :content, :status, :deadline)
    end

    def deadline
    end
end
