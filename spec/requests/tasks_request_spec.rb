require 'rails_helper'

RSpec.describe 'Tasks', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user, email: "other@example.com") }
  let(:task) { create(:task, user_id: user.id) }
  let(:other_task) { create(:task, user_id: other_user.id) }
  subject { get get_action_url }

  describe 'index action' do
    let(:get_action_url) { tasks_path }
    it 'return 200' do
      is_expected.to eq 200
    end
  end

  describe 'show action' do
    let(:get_action_url) { tasks_path(task) }
    it 'return 200' do
      is_expected.to eq 200
    end
  end

  describe 'new action' do
    let(:get_action_url) { new_task_path }
    context 'when user logged in' do
      before { sign_in user }
      it 'return 200' do
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
  end

  describe 'edit action' do
    context 'when user logged' do
      before do
        sign_in user
      end
      context 'edit my task' do
        let(:get_action_url) { edit_task_path(task) }
        it 'return 200' do
          is_expected.to eq 200
        end
      end
      context "edit other people's task" do
        # let(:get_action_url) { edit_task_path(other_task) }
        it 'return 404 error' do
          expect {
            get edit_task_path(other_task)
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
    context "when user not llogged in" do
    end
  end

  describe 'update action' do
  end

  describe 'destroy action' do
  end

  describe 'myself action' do
  end

  describe 'edit_assignment action' do
  end

  describe 'update_assignment action' do
  end
end
