require 'rails_helper'

RSpec.describe 'Tasks', type: :request do
  let(:user)        { create(:user) }
  let(:other_user)  { create(:user) }
  let!(:mytask)     { create(:task, user_id: user.id, title: 'my task') }
  let!(:other_task) { create(:task, user_id: other_user.id, title: 'other task') }

  shared_examples :success_request do |template_name|
    it { is_expected.to eq 200 }
    it { is_expected.to render_template(template_name) }
  end

  describe 'index action' do
    subject { get tasks_path }
    it_behaves_like :success_request, :index
  end

  describe 'show action' do
    subject { get task_path(task_type) }
    context 'when user logged in' do
      before  { sign_in user }
      context 'mytask' do
        let(:task_type) { mytask }
        it 'request succeds' do
          is_expected.to eq 200
        end
        it "'アサイン' is displayed'" do
          subject
          expect(response.body).to include('アサイン')
        end
        it "'編集' is displayed'" do
          subject
          expect(response.body).to include('編集')
        end
      end
      context "other user's task" do
        let(:task_type) { other_task }
        it 'request succeds' do
          is_expected.to eq 200
        end
        it "'アサイン' is not displayed'" do
          subject
          expect(response.body).to_not include('アサイン')
        end
        it "'編集' is not displayed'" do
          subject
          expect(response.body).to_not include('編集')
        end
      end
    end
    context 'when user not logged in' do
      let(:task_type) { other_task }
      it 'request succeds' do
        is_expected.to eq 200
      end
      it "'アサイン' is not displayed'" do
        subject
        expect(response.body).to_not include('アサイン')
      end
      it "'編集' is not displayed'" do
        subject
        expect(response.body).to_not include('編集')
      end
    end
  end

  describe 'new action' do
    subject { get new_task_path }
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
    subject { post tasks_path, params: { task: attributes_for(:task, title: task_title) } }
    context 'when user logged in' do 
      before { sign_in user }
      context 'valid information' do
        let(:task_title) { "create task" }
        it 'the number of tasks increases by 1' do
          expect{ subject }.to change(Task, :count).by(1)
        end
        it 'redirect_to myself_tasks_path' do
          is_expected.to redirect_to myself_tasks_path
        end
        it 'the created task is displayed' do
          subject
          expect(response.body).to_not include('create task')
        end
      end
      context 'invalid information' do
        let(:task_title) { " " }
        it 'the number of tasks does not increase' do
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
      let(:task_title) { "create task" }
      it "redirect to 'users/sign_in'" do
        is_expected.to redirect_to new_user_session_path
      end
    end
  end

  describe 'edit action' do
    subject { get edit_task_path(task_type) }
    context 'when user logged in' do
      before { sign_in user }
      context 'Access mytask edit screen' do
        let(:task_type) { mytask }
        it 'request succeds' do
          is_expected.to eq 200
        end
        it 'title is displayed in the edit form' do
          subject
          expect(response.body).to include(mytask.title)
        end
        it 'content is displayed in the edit form' do
          subject
          expect(response.body).to include(mytask.content)
        end
      end
      context "Access other user's task edit screen" do
        let(:task_type) { other_task }
        it 'return 404 error' do
          expect{ subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
    context 'when user not logged in' do
      let(:task_type) { other_task }
      it "redirect to 'users/sign_in'" do
        is_expected.to redirect_to new_user_session_path
      end
    end
  end

  describe 'update action' do
    subject { patch task_path(task_type), params: { task: attributes_for(:task, title: task_title) } }
    context 'when user logged in' do
      before { sign_in user }
      context 'update mytask' do
        context 'valid information' do
          let(:task_type)  { mytask }
          let(:task_title) { "Update task" }
          it "change title from 'test title' to 'update title'" do
            subject
            expect(mytask.reload.title).to eq "Update task"
          end
          it 'redirect to myself_tasks_path' do
            is_expected.to redirect_to myself_tasks_path
          end
        end
        context 'invalid information' do
          let(:task_type)  { mytask }
          let(:task_title) { " " }
          it "task title cannot update from 'test title' to empty field" do
            subject
            expect(mytask.reload.title).to_not eq " "
          end
          it 'render tasks/edit' do
            is_expected.to render_template :edit
          end
        end
      end
      context "update other user's task" do
        let(:task_type)  { other_task }
        let(:task_title) { "Update task" }
        it 'return 404 error' do
          expect{ subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
    context 'when user not logged in' do
      let(:task_type)  { other_task }
      let(:task_title) { "Update task" }
      it "redirect to 'users/sign_in'" do
        is_expected.to redirect_to new_user_session_path
      end
    end
  end

  describe 'destroy action' do
    subject { delete task_path(task_type) }
    context 'when user logged in' do
      before { sign_in user }
      context 'destroy mytask' do
        let(:task_type) { mytask }
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
        let(:task_type) { other_task }
        it 'return 404 error' do
          expect{ subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
    context 'when user not logged in' do
      let(:task_type) { other_task }
      it "redirect to 'users/sign_in'" do
        is_expected.to redirect_to new_user_session_path
      end
    end
  end

  describe 'myself action' do
    subject { get myself_tasks_path }
    context 'when user logged in' do
      before { sign_in user }
      it 'request succeds' do
        is_expected.to eq 200
      end
      it 'mytask is displayed' do
        subject
        expect(response.body).to include('my task')
      end
      it 'other task is not displayed' do
        subject
        expect(response.body).to_not include('other task')
      end
    end
    context 'when user not logged in' do
      it "redirect to 'users/sign_in'" do
        is_expected.to redirect_to new_user_session_path
      end
    end
  end

  describe 'edit_assignment action' do
    subject { get edit_assignment_task_path(task_type) }
    context 'when user logged in' do
      before { sign_in user }
      context 'access my task assignment edit screen' do
        let(:task_type) { mytask }
        it 'request succeds' do
          is_expected.to eq 200
        end
      end
      context "access other user's task assignment edit screen" do
        let(:task_type) { other_task }
        it 'return 404 error' do
          expect{ subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
    context 'when user not logged in' do
      let(:task_type) { other_task }
      it "redirect to 'users/sign_in'" do
        is_expected.to redirect_to new_user_session_path
      end
    end
  end

  describe 'update_assignment action' do
    subject { patch update_assignment_task_path(task_type), { params: { user_id: user_type.id } } }
    context 'when user logged in' do
      before { sign_in user }
      context 'update my task assignment' do
        let(:task_type) { mytask }
        let(:user_type) { other_user }
        it 'change user_id from user.id to other_user.id' do
          subject
          expect(mytask.reload.user_id).to eq other_user.id
        end
        it 'redirect to tasks_path' do
          is_expected.to redirect_to tasks_path
        end
      end
      context "update other user's task assignment" do
        let(:task_type) { other_user }
        let(:user_type) { user }
        it 'return 404 error' do
          expect{ subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
    context 'when user not logged in' do
      let(:task_type) { other_user }
      let(:user_type) { user }
      it "redirect to 'users/sign_in'" do
        is_expected.to redirect_to new_user_session_path
      end
    end
  end
end
