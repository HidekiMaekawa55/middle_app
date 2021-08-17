require 'rails_helper'

RSpec.describe 'Tasks', type: :request do
  let(:user)        { create(:user) }
  let(:other_user)  { create(:user) }
  let!(:task)       { create(:task, user_id: user.id, title: 'my task') }
  let!(:other_task) { create(:task, user_id: other_user.id, title: 'other task') }
  let(:build_task)  { build(:task) }
  subject { get get_action_url }

  describe 'index action' do
    before { create(:task, user_id: user.id, title: 'Completed task', status: "完了") }
    let(:get_action_url) { tasks_path }
    it 'request succeds' do
      is_expected.to eq 200
    end
    it 'completed status are not displayed' do
      subject
      expect(response.body).to_not include('Completed task')
    end
  end

  describe 'show action' do
    let(:get_action_url) { tasks_path(task) }
    it 'request succeds' do
      is_expected.to eq 200
    end
  end

  describe 'new action' do
    let(:get_action_url) { new_task_path }
    context 'when user logged in' do
      before { sign_in user }
      it 'request succeds' do
        is_expected.to eq 200
      end
    end
    context 'when user not logged in' do
      it "redirect_to 'users/sign_in'" do
        is_expected.to redirect_to new_user_session_path
      end
    end
  end

  describe 'create action' do
    context 'when user logged in' do 
      before { sign_in user }
      context 'Success task creation' do
        subject { post tasks_path, params: { task: attributes_for(:task) } }
        it 'The number of tasks increases by 1' do
          expect{ subject }.to change(Task, :count).by(1)
        end
        it 'redirect_to myself_tasks_path' do
          is_expected.to redirect_to myself_tasks_path
        end
      end
      context 'Fails task creation' do
        subject { post tasks_path, params: { task: attributes_for(:task, title: " " ) } }
        it 'The number of tasks does not increase' do
          expect{ subject }.to change(Task, :count).by(0)
        end
        it 'render tasks/new' do
          is_expected.to render_template :new
        end
        it 'get a alert flash messages' do
          subject
          expect(response.body).to include("titleを入力してください")
        end
      end
    end
    context 'when user not logged in' do
      subject { post tasks_path, params: { task: build_task } }
      it "redirect to 'users/sign_in'" do
        is_expected.to redirect_to new_user_session_path
      end
    end
  end

  describe 'edit action' do
    context 'when user logged in' do
      before do
        sign_in user
      end
      context 'Access my task edit screen' do
        let(:get_action_url) { edit_task_path(task) }
        it 'request succeds' do
          is_expected.to eq 200
        end
      end
      context "Access other user's task edit screen" do
        let(:get_action_url) { edit_task_path(other_task) }
        it 'return 404 error' do
          expect{ subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
    context 'when user not logged in' do
      let(:get_action_url) { edit_task_path(task) }
      it "redirect to 'users/sign_in'" do
        is_expected.to redirect_to new_user_session_path
      end
    end
  end

  describe 'update action' do
    context 'when user logged in' do
      before { sign_in user }
      context 'update my task' do
        context 'Success task update' do
          subject { patch task_path(task), params: { task: attributes_for(:task, title: "update title") } }
          it "change title from 'test title' to 'update title'" do
            subject
            expect(task.reload.title).to eq "update title"
          end
          it 'redirect to myself_tasks_path' do
            is_expected.to redirect_to myself_tasks_path
          end
        end
        context 'Fails task update' do
          subject { patch task_path(task), params: { task: attributes_for(:task, title: " ") } }
          it "task title cannot update from 'test title' to empty field" do
            subject
            expect(task.reload.title).to_not eq " "
          end
          it 'render tasks/edit' do
            is_expected.to render_template :edit
          end
        end
      end
      context "update other user's task" do
        subject { patch task_path(other_task) }
        it 'return 404 error' do
          expect{ subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
    context 'when user not logged in' do
      subject { patch task_path(task) }
      it "redirect to 'users/sign_in'" do
        is_expected.to redirect_to new_user_session_path
      end
    end
  end

  describe 'destroy action' do
    context 'when user logged in' do
      before { sign_in user }
      context 'destroy my task' do
        subject { delete task_path(task) }
        it '1 task has been reduced' do
          expect{ subject }.to change(Task, :count).by(-1)
        end
        it 'redirect_to tasks_path' do
          is_expected.to redirect_to tasks_path
        end
        it 'get a notice flash message' do
          subject
          expect(flash[:notice]).to be_truthy
        end
      end
      context "destroy other user's task" do
        subject { delete task_path(other_task) }
        it 'return 404 error' do
          expect{ subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
    context 'when user not logged in' do
      subject { delete task_path(task) }
      it "redirect to 'users/sign_in'" do
        is_expected.to redirect_to new_user_session_path
      end
    end
  end

  describe 'myself action' do
    context 'when user logged in' do
      before { sign_in user}
      let(:get_action_url) { myself_tasks_path }
      it 'request succeds' do
        is_expected.to eq 200
      end
      it 'current user task is displayed' do
        subject
        expect(response.body).to include('my task')
      end
      it 'other user task is not displayed' do
        subject
        expect(response.body).to_not include('other task')
      end
      it 'completed status are not displayed' do
        subject
        expect(response.body).to_not include('Completed task')
      end
    end
    context 'when user not logged in' do
      let(:get_action_url) { myself_tasks_path }
      it "redirect to 'users/sign_in'" do
        is_expected.to redirect_to new_user_session_path
      end
    end
  end

  describe 'edit_assignment action' do
    context 'when user logged in' do
      before { sign_in user }
      context 'Access my task assignment edit screen' do
        let(:get_action_url) { edit_assignment_task_path(task) }
        it 'request succeds' do
          is_expected.to eq 200
        end
      end
      context "Access other user's task assignment edit screen" do
        let(:get_action_url) { edit_assignment_task_path(other_task) }
        it 'return 404 error' do
          expect{ subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
    context 'when user not logged in' do
      let(:get_action_url) { edit_assignment_task_path(task) }
      it "redirect to 'users/sign_in'" do
        is_expected.to redirect_to new_user_session_path
      end
    end
  end

  describe 'update_assignment action' do
    context 'when user logged in' do
      before { sign_in user }
      context 'update my task assignment' do
        subject { patch update_assignment_task_path(task), { params: { user_id: other_user.id } } }
        it 'change user_id from user.id to other_user.id' do
          subject
          expect(task.reload.user_id).to eq other_user.id
        end
        it 'redirect to tasks_path' do
          is_expected.to redirect_to tasks_path
        end
      end
      context "update other user's task assignment" do
        subject { patch update_assignment_task_path(other_task), { params: { user_id: user.id } } }
        it 'return 404 error' do
          expect{ subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
    context 'when user not logged in' do
      subject { patch update_assignment_task_path(task), { params: { user_id: other_user.id } } }
      it "redirect to 'users/sign_in'" do
        is_expected.to redirect_to new_user_session_path
      end
    end
  end
end
