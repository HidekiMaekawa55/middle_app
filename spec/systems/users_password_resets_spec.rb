require 'rails_helper'

RSpec.describe 'users password resets', type: :system do
  let(:user) { create(:user) }
  let(:user_last) { User.last }
  before { visit new_user_password_path }

  context 'valid information' do
    before do
      fill_in 'Eメール', with: user.email
      click_button 'Send me reset password instructions'
    end
    it "redirect to 'users/sign_in'" do
      expect(page).to have_current_path new_user_session_path
    end
    it 'get a notice message' do
      expect(page).to have_selector('.notice', text: 'パスワードの再設定について数分以内にメールでご連絡いたします。')
    end
    it 'has been sent confirmation email' do
      expect(ActionMailer::Base.deliveries.size).to eq(1)
    end
    context 'Authenticate user email address with valid information' do
      before { visit edit_user_password_path(reset_password_token: user_last.reset_password_token) }
      it "'change your password’ is displayed"  do
        expect(page).to have_content 'Change your password'
      end
      context 'Enter the new valid password' do
      end
      context 'Enter the new invalid password' do
      end
    end
  end
end