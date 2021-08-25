class TasksController < ApplicationController
  before_action :set_task,           only: [:show]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :myself, :edit_assignment, :update_assignment]
  before_action :set_mytask,         only: [:edit, :update, :destroy, :edit_assignment, :update_assignment]

  def index
    tasks     = Task.incomplete(params[:status],params[:keyword]).includes(:user)
    @per_page = params[:per_page]
    @tasks    = tasks.page(params[:page]).per(@per_page)
  end

  def show
  end

  def new
    @task = Task.new
  end

  def create
    @task = current_user.tasks.build(task_params)
    if @task.save
      redirect_to myself_tasks_path, notice: '正しく作成されました。'
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @task.update(task_params)
      redirect_to myself_tasks_path, notice: "タスク#{@task.id}を編集しました。"
    else
      render 'edit'
    end
  end

  def destroy
    @task.destroy
    redirect_to tasks_path, notice: "タスク#{@task.id}を削除しました"
  end

  def myself 
    tasks  = current_user.tasks.incomplete(params[:keyword]).includes(:user) 
    @tasks = tasks.page(params[:page]).per(16)
  end

  def edit_assignment
    @users = User.all
  end

  def update_assignment
    @task.update(user_id: params[:user_id])
    redirect_to tasks_path, notice: "タスク#{@task.id}の担当者を変更しました。"
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
