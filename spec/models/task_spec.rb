require 'rails_helper'

RSpec.describe Task, type: :model do
  let(:user) { create(:user) }
  it 'has a valid factory bot' do
    expect(build(:task, user_id: user.id)).to be_valid
  end

  describe 'validation' do
    context 'presence: true' do
      %w{title content deadline status user_id}.each do |column_name|
        let(:task) { build(:task, user_id: user.id) }
        it "is invalid with a blank #{column_name}" do
          task[column_name] = ' '
          expect(task).to be_invalid
        end
      end
    end
  end
end