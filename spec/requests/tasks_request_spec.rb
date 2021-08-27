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
  shared_examples :return_404_error do
    it { expect{ subject }.to raise_error(ActiveRecord::RecordNotFound) }
  end
  shared_examples :redirect_to_sign_in_page do
    it { is_expected.to redirect_to new_user_session_path }
  end

  describe 'index action' do
    subject { get tasks_path }
    it_behaves_like :success_request, :index
  end

  describe 'show action' do
    subject { get task_path(mytask) }
    it_behaves_like :success_request, :show
  end

  describe 'new action' do
    subject { get new_task_path }
    context 'when user logged in' do
      before { sign_in user }
      it_behaves_like :success_request, :new
    end
    context 'when user not logged in' do
      it_behaves_like :redirect_to_sign_in_page
    end
  end

  describe 'create action' do
    subject { post tasks_path, params: { task: attributes_for(:task, title: task_title) } }
    context 'when user logged in' do 
      before { sign_in user }
      context 'valid information' do
        let(:task_title) { "create task" }
        it { expect{ subject }.to change(Task, :count).by(1) }
        it { is_expected.to redirect_to myself_tasks_path }
      end
      context 'invalid information' do
        let(:task_title) { " " }
        it { expect{ subject }.to change(Task, :count).by(0) }
        it { is_expected.to render_template :new }
      end
    end
    context 'when user not logged in' do
      let(:task_title) { "create task" }
      it_behaves_like :redirect_to_sign_in_page
    end
  end

  describe 'edit action' do
    subject { get edit_task_path(task_type) }
    context 'when user logged in' do
      before { sign_in user }
      context 'Access mytask edit screen' do
        let(:task_type) { mytask }
        it_behaves_like :success_request, :edit
      end
      context "Access other user's task edit screen" do
        let(:task_type) { other_task }
        it_behaves_like :return_404_error
      end
    end
    context 'when user not logged in' do
      let(:task_type) { other_task }
      it_behaves_like :redirect_to_sign_in_page
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
          it do
            subject
            expect(mytask.reload.title).to eq "Update task"
          end
          it { is_expected.to redirect_to myself_tasks_path }
        end
        context 'invalid information' do
          let(:task_type)  { mytask }
          let(:task_title) { " " }
          it do
            subject
            expect(mytask.reload.title).to_not eq " "
          end
          it { is_expected.to render_template :edit }
        end
      end
      context "update other user's task" do
        let(:task_type)  { other_task }
        let(:task_title) { "Update task" }
        it_behaves_like :return_404_error
      end
    end
    context 'when user not logged in' do
      let(:task_type)  { other_task }
      let(:task_title) { "Update task" }
      it_behaves_like :redirect_to_sign_in_page
    end
  end

  describe 'destroy action' do
    subject { delete task_path(task_type) }
    context 'when user logged in' do
      before { sign_in user }
      context 'destroy mytask' do
        let(:task_type) { mytask }
        it { expect{ subject }.to change(Task, :count).by(-1) }
        it { is_expected.to redirect_to tasks_path }
      end
      context "destroy other user's task" do
        let(:task_type) { other_task }
        it_behaves_like :return_404_error
      end
    end
    context 'when user not logged in' do
      let(:task_type) { other_task }
      it_behaves_like :redirect_to_sign_in_page
    end
  end

  describe 'myself action' do
    subject { get myself_tasks_path }
    context 'when user logged in' do
      before { sign_in user }
      it_behaves_like :success_request, :myself
    end
    context 'when user not logged in' do
      it_behaves_like :redirect_to_sign_in_page
    end
  end

  describe 'edit_assignment action' do
    subject { get edit_assignment_task_path(task_type) }
    context 'when user logged in' do
      before { sign_in user }
      context 'access my task assignment edit screen' do
        let(:task_type) { mytask }
        it_behaves_like :success_request, :edit_assignment
      end
      context "access other user's task assignment edit screen" do
        let(:task_type) { other_task }
        it_behaves_like :return_404_error
      end
    end
    context 'when user not logged in' do
      let(:task_type) { other_task }
      it_behaves_like :redirect_to_sign_in_page
    end
  end

  describe 'update_assignment action' do
    subject { patch update_assignment_task_path(task_type), { params: { user_id: user_type.id } } }
    context 'when user logged in' do
      before { sign_in user }
      context 'update my task assignment' do
        let(:task_type) { mytask }
        let(:user_type) { other_user }
        it do
          subject
          expect(mytask.reload.user_id).to eq other_user.id
        end
        it { is_expected.to redirect_to tasks_path }
      end
      context "update other user's task assignment" do
        let(:task_type) { other_user }
        let(:user_type) { user }
        it_behaves_like :return_404_error
      end
    end
    context 'when user not logged in' do
      let(:task_type) { other_user }
      let(:user_type) { user }
      it_behaves_like :redirect_to_sign_in_page
    end
  end
end
