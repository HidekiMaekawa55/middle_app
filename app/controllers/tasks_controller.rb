class TasksController < ApplicationController
  before_action :apple, only: [:new, :create, :edit, :update, :destroy]

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
  end

  def destroy
  end

  def myself 
    @user = current_user
    @tasks = Task.index_myself(@user)
  end

  private
    def task_params
      params.require(:task).permit(:title, :content, :status, :deadline)
    end

    def apple
      unless user_signed_in?
        redirect_to new_user_registration_path
        flash[:danger] = "この機能にはアカウント登録が必要です。"
      end
    end
end
