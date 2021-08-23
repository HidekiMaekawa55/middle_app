require 'rails_helper'

RSpec.describe 'users email edit', type: :system do
  let(:user) { create(:user) }
  before do
    visit new_user_session_path
    fill_in 'Eメール',          with: user.email
    fill_in 'パスワード',       with: user.password
    click_button 'Log in'
  end

  context 'valid edit information' do
    before do
      visit edit_user_registration_path 
      fill_in 'Eメール',          with: 'edit_email@example.com'
      fill_in '現在のパスワード',   with: user.password
      click_button 'Update'
    end
    it 'redirect to root_path' do
      expect(page).to have_current_path root_path
    end
    it 'get a notice message' do
      expect(page).to have_selector('.notice', text: '本人確認用メールより確認処理をおこなってください。')
    end
    it 'has been sent one confirmation email' do
      expect(ActionMailer::Base.deliveries.size).to eq(1)
    end
    it 'email address has not changed yet' do
      expect(user.reload.email).to_not eq 'edit_email@example.com'
    end
    context "Authenticate user's new email address with valid information" do
      before { visit user_confirmation_path(confirmation_token: user.reload.confirmation_token) }
      it 'redirect to root_path' do
        expect(page).to have_current_path root_path
      end
      it 'get a notice message' do
        expect(page).to have_selector('.notice', text: 'メールアドレスが確認できました。')
      end
      it "email address has changed to 'edit_email@example.com'" do
        expect(user.reload.email).to eq 'edit_email@example.com'
      end
    end
  end

  context 'invalid edit information' do
    context 'invalid email address' do
      before do
        visit edit_user_registration_path 
        fill_in 'Eメール',          with: ' '
        fill_in '現在のパスワード', with: user.password
        click_button 'Update'
      end
      it 'get a alert message' do
        expect(page).to have_selector('.alert')
      end
      it 'has not been sent confirmation email' do
        expect(ActionMailer::Base.deliveries.size).to eq(0)
      end
    end
    context 'invalid current password' do
      before do
        visit edit_user_registration_path 
        fill_in 'Eメール',          with: 'edit_email@example.com'
        fill_in '現在のパスワード',   with: 'invalid'
        click_button 'Update'
      end
      it 'get a alert message' do
        expect(page).to have_selector('.alert', text: '現在のパスワードは不正な値です')
      end
      it 'has not been sent confirmation email' do
        expect(ActionMailer::Base.deliveries.size).to eq(0)
      end
    end
  end
end