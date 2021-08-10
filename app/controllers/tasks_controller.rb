class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy]
  before_action :sign_now, only: [:new, :create, :edit, :update, :destroy, :myself]

  def index
    @tasks = Task.index_all
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
      redirect_to tasks_path
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
    @user = current_user
    @tasks = Task.index_myself(@user)
  end

  private
    def set_task
      @task = Task.find(params[:id])
    end

    def task_params
      params.require(:task).permit(:title, :content, :status, :deadline)
    end

    def sign_now
      unless user_signed_in?
        redirect_to new_user_registration_path
        flash[:alert] = "この機能にはアカウント登録が必要です。"
      end
    end
end
