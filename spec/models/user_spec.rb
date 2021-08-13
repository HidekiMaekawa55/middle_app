require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has a valid factory bot' do
    expect(build(:user)).to be_valid
  end

  describe 'validation' do
    context 'presence: true' do
      it 'is invalid with a blank email' do
        user = build(:user, email: ' ')
        expect(user).to be_invalid
      end
      it 'is invalid with a blank password' do
        user = build(:user, password: ' ' * 6)
        expect(user).to be_invalid
      end
    end
    context 'uniquness: true' do
      let!(:user) { create(:user, email: 'original@example.com')}
      it 'is invalid with a duplicate email' do
        user = build(:user, email: 'original@example.com')
        expect(user).to be_invalid
      end
    end
    context 'length: { minimum: 6 }' do
      it 'is invalid with a 5 words password' do
        user = build(:user, password: "a" * 5, password_confirmation: "a" * 5)
        expect(user).to be_invalid
      end
    end
  end
end
