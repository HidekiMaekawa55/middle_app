class TasksController < ApplicationController
  before_action :set_task,     only: [:show, :edit, :update, :destroy, :edit_assignment, :update_assignment]
  before_action :logged_in_user,     only: [:new, :create, :edit, :update, :destroy, :myself]
  before_action :can_edit_myself_task, only: [:edit, :update, :destroy, :edit_assignment, :update_assignment]

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
    @user = current_user
    @tasks = Task.index_myself(@user)
  end

  def edit_assignment
    @users = User.user_all
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

    def logged_in_user
      unless user_signed_in?
        redirect_to new_user_registration_path
        flash[:alert] = "この機能にはアカウント登録が必要です。"
      end
    end

    def can_edit_myself_task
      unless @task.user == current_user
        redirect_to tasks_path
        flash[:alert] = "自分のタスクしか編集できません。"
      end
    end
end
