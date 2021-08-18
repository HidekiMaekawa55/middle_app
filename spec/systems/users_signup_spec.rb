require 'rails_helper'

RSpec.describe 'users signup', type: :system do
  subject { page }
  let(:user) { build(:user) }
  let(:user_last) { User.last }
  context 'valid signup information' do
    before do
      visit new_user_registration_path 
      fill_in 'ユーザ名',           with: user.name
      fill_in 'Eメール',           with: user.email
      fill_in 'パスワード',         with: user.password
      fill_in 'パスワード（確認用）', with: user.password
      click_button 'Sign up'
    end
    it 'get a notice message' do
      is_expected.to have_selector('.notice', text: '本人確認用のメールを送信しました。メール内のリンクからアカウントを有効化させてください。')
    end
    it 'redirect to root_path' do
      is_expected.to have_current_path root_path
    end
    it 'has been sent confirmation email' do
      expect(ActionMailer::Base.deliveries.size).to eq(1)
    end
    it 'confirmed_at is nil' do
      expect(user_last.confirmed_at).to eq nil
    end
    context 'Log in without user.email confirmation' do
      before do
        visit new_user_session_path
        fill_in 'Eメール',   with: user.email
        fill_in 'パスワード', with: user.password
        click_button 'Log in'
      end
      it 'get a alert message（メールアドレスの本人確認が必要です。)' do
        is_expected.to have_selector('.alert', text: 'メールアドレスの本人確認が必要です。')
      end
      it 'render :new' do
        is_expected.to have_current_path new_user_session_path
      end
    end
    context 'Confirm user email address with valid information' do
      before { visit user_confirmation_path(confirmation_token: user_last.confirmation_token) }
      it 'get a notice message（メールアドレスが確認できました。)' do
        is_expected.to have_selector('.notice', text: 'メールアドレスが確認できました。')
      end
      it 'the value is entered in confirmed_at' do
        expect(user_last.reload.confirmed_at).to_not eq nil
      end
      context 'Log in with user.email confirmation' do
        before do
          visit new_user_session_path
          fill_in 'Eメール',   with: user.email
          fill_in 'パスワード', with: user.password
          click_button 'Log in'
        end
        it 'get a notice message（ログインしました)' do
          is_expected.to have_selector('.notice', text: 'ログインしました。')
        end
      end
    end
    context 'Confirm user email address with invalid information' do
      before { visit user_confirmation_path(confirmation_token: 'invalid') }
      it 'get a alert message（パスワード確認用トークンは不正な値です)' do
        is_expected.to have_selector('.alert', text: 'パスワード確認用トークンは不正な値です')
      end
      context 'Resend confirmation instructions' do
        before do
          ActionMailer::Base.deliveries.clear
          fill_in 'Eメール',   with: user.email
          click_button 'Resend confirmation instructions'
        end
        it 'get a notice message（アカウントの有効化について数分以内にメールでご連絡します。)' do
          is_expected.to have_selector('.notice', text: 'アカウントの有効化について数分以内にメールでご連絡します。')
        end
        it 'has been sent resend confirmation email' do
          expect(ActionMailer::Base.deliveries.size).to eq(1)
        end
      end
    end
  end
end