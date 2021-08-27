require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has a valid factory bot' do
    expect(build(:user)).to be_valid
  end

  describe 'validation' do
    subject { user }
    context 'presence: true' do
      context 'email' do
        let(:user) { build(:user, email: ' ') }
        it { is_expected.to be_invalid }
      end
      context 'password' do
        let(:user) { build(:user, password: ' ' * 6) }
        it { is_expected.to be_invalid }
      end
    end
    context 'uniquness: true' do
      let!(:first_user) { create(:user, email: 'original@example.com')}
      context 'email' do
        let(:user) { build(:user, email: 'original@example.com') }
        it { is_expected.to be_invalid }
      end
    end
    context 'length: { minimum: 6 }' do
      context 'password' do
        let(:user) { build(:user, password: "a" * 5, password_confirmation: "a" * 5) }
        it { is_expected.to be_invalid }
      end
    end
  end 
end
