require 'rails_helper'

RSpec.describe 'site layout', type: :system do
  subject { page }
  before { visit root_path }
  let(:user) { create(:user) }
  
  context 'Access to root_path when not logged in' do
    it 'has the correct header links' do
      is_expected.to have_link 'タスク管理アプリ',     href: tasks_path
      is_expected.to have_link 'タスク一覧',    href: tasks_path
      is_expected.to have_link 'サインアップ',   href: new_user_registration_path
      is_expected.to have_link 'ログイン',    href: new_user_session_path
    end
  end
  context 'Access to root_path when logged in' do
    before do
      click_link('ログイン')
      fill_in('Eメール', with: user.email)
      fill_in('パスワード', with: user.password)
      click_button('Log in')  
    end
    it 'has the correct header links' do
      is_expected.to_not have_link 'サインアップ',  href: new_user_registration_path
      is_expected.to_not have_link 'ログイン', href: new_user_session_path
      is_expected.to have_link 'マイタスク',     href: myself_tasks_path 
      is_expected.to have_link 'ユーザ設定',     href: edit_user_registration_path
      is_expected.to have_link 'ログアウト',     href: destroy_user_session_path
    end
  end
end