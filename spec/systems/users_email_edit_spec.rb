require 'rails_helper'

RSpec.describe 'users email edit', type: :system do
  let(:user) { create(:user) }
  context 'valid edit information' do
    before do
      visit new_user_session_path
      fill_in 'Eメール',          with: user.email
      fill_in 'パスワード',       with: user.password
      click_button 'Log in'
      visit edit_user_registration_path 
      fill_in 'Eメール',          with: 'edit_email@example.com'
      fill_in '現在のパスワード', with: user.password
      click_button 'Update'
    end
    it 'redirect to root_path' do
      expect(page).to have_current_path root_path
    end
    it 'get a notice message' do
      expect(page).to have_selector('.notice', text: 'アカウント情報を変更しました。変更されたメールアドレスの本人確認のため、本人確認用メールより確認処理をおこなってください。')
    end
  end
end