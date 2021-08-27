require 'rails_helper'

RSpec.describe Task, type: :model do
  let(:user) { create(:user) }
  let(:task) { build(:task, user_id: user.id) }
  it 'has a valid factory bot' do
    expect(build(:task, user_id: user.id)).to be_valid
  end

  describe 'validation' do
    context 'presence: true' do
      shared_examples :expect_task_to_be_invalid do |column_name|
        it do
          task[column_name] = ' '
          expect(task).to be_invalid
        end
      end
      context 'blank title' do
        it_behaves_like :expect_task_to_be_invalid, "title"
      end
      context 'blank content' do
        it_behaves_like :expect_task_to_be_invalid, "content"
      end
      context 'blank deadline' do
        it_behaves_like :expect_task_to_be_invalid, "deadline"
      end
      context 'blank status' do
        it_behaves_like :expect_task_to_be_invalid, "status"
      end
      context 'blank user_id' do
        it_behaves_like :expect_task_to_be_invalid, "user_id"
      end
    end
  end
end