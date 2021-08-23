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
      # before { visit edit_user_password_path(reset_password_token: user.reload.reset_password_token) }
      before do
        password_reset_mail = ActionMailer::Base.deliveries.last 
        mail_body = password_reset_mail.body.encoded
        password_reset_url = URI.extract(mail_body)[0]
        visit password_reset_url
      end
      it "'change your password’ is displayed"  do
        expect(page).to have_content 'Change your password'
      end
      context 'Enter the valid new password information' do
        before do
          fill_in 'New password', with: 'password2'
          fill_in 'Confirm new password', with: 'password'
          click_button 'Change my password'
        end
        # it 'redirect to root_path' do
        #   expect(page).to have_current_path root_path
        # end
        # it 'get a notice message' do
        #   expect(page).to have_selector('.notice', text: 'パスワードが正しく変更されました。')
        # end
      end
      context 'Enter the invalid new password information' do
      end
    end
  end
end