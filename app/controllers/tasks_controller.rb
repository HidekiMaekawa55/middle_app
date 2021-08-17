class TasksController < ApplicationController
  before_action :set_task,           only: [:show]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :myself, :edit_assignment, :update_assignment]
  before_action :set_mytask,         only: [:edit, :update, :destroy, :edit_assignment, :update_assignment]

  def index
    @tasks = Task.incomplete.includes(:user) 
  end

  def show
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.new(task_params)
    @task.user_id = current_user.id
    if @task.save
      redirect_to myself_tasks_path
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @task.update(task_params)
      redirect_to myself_tasks_path
    else
      render 'edit'
    end
  end

  def destroy
    @task.destroy
    redirect_to tasks_path
    flash[:notice] = "タスク#{@task.id}を削除しました"
  end

  def myself 
    @tasks = current_user.tasks.incomplete.includes(:user) 
  end

  def edit_assignment
    @users = User.all
  end

  def update_assignment
    @task.update(user_id: params[:user_id])
    redirect_to tasks_path
  end

  private
    def set_task
      @task = Task.find(params[:id])
    end

    def task_params
      params.require(:task).permit(:title, :content, :status, :deadline)
    end

    def set_mytask
      @task = current_user.tasks.find(params[:id])
    end
end
