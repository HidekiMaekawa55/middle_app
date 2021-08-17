require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let(:user) { create(:user) }
  let(:user_params) { attributes_for(:user) }
  let(:invalid_user_params) { attributes_for(:user, email: " " )}

  describe 'get #sign_up' do
    subject { get new_user_registration_path }
    context 'when user logged in' do
      before { sign_in user }
      it 'redirect to root_path' do
        is_expected.to redirect_to root_path
      end
      it 'get a alert message' do
        subject
        expect(flash[:alert]).to be_truthy
      end
    end
    context 'when user not logged in' do
      it 'request succeds' do
        is_expected.to eq 200
      end
    end
  end

  describe 'post registrations#create (sign up)' do
    context 'valid information' do
      subject { post user_registration_path, params: { user: user_params } }
      it 'request succeeds' do
        is_expected.to eq 302
      end
      it 'has been sent one email' do
        expect{ subject }.to change(ActionMailer::Base.deliveries, :count).by(1)
      end
      it 'redirect to root_path' do
        is_expected.to redirect_to root_path
      end
      it 'The number of users increases by 1' do
        expect{ subject }.to change(User, :count).by(1)
      end
    end
    context 'invalid information' do
      subject { post user_registration_path, params: { user: invalid_user_params } }
      it 'has not been sent one email' do
        expect{ subject }.to change(ActionMailer::Base.deliveries, :count).by(0)
      end
      it 'render :new' do
        is_expected.to render_template :new
      end
      it 'the number of users does not increase' do
        expect{ subject }.to change(User, :count).by(0)
      end
    end
  end

  describe 'get #sign_in' do
    subject { get new_user_session_path }
    context 'when user logged in' do
      before { sign_in user }
      it 'redirect to root_path' do
        is_expected.to redirect_to root_path
      end
      it 'get a alert message' do
        subject
        expect(flash[:alert]).to be_truthy
      end
    end
    context 'when user not logged in' do
      it 'request succeds' do
        is_expected.to eq 200
      end
    end
  end

  describe 'post sessions#create (sign in)' do
    context 'valid information' do
      subject { post user_session_path, params: { user: { email: user.email, password: user.password } } }
      it 'request succeds' do
        is_expected.to redirect_to root_path
      end
      it 'get a notice message (ログインしました。)' do
        subject
        expect(flash[:notice]).to eq('ログインしました。')
      end
    end
    context 'invalid information' do
      subject { post user_session_path, params: { user: invalid_user_params } }
      it 'render :new' do
        is_expected.to render_template :new
      end
      it 'get a alert message(Eメールまたはパスワードが違います。)' do
        subject
        expect(flash[:alert]).to eq('Eメールまたはパスワードが違います。')
      end
    end
  end

  describe 'get #edit' do
    context 'when user logged in' do
      before { sign_in user }
      subject { get edit_user_registration_path }
      it 'request succeds' do
        is_expected.to eq 200
      end
      it 'user.name is displayed' do
        subject
        expect(response.body).to include(user.name)
      end
      it 'user.email is displayed' do
        subject
        expect(response.body).to include(user.email)
      end
    end
    context 'when user not logged in' do
      subject { get edit_user_registration_path }
      it "redirect to 'users/sign_in'" do
        is_expected.to redirect_to new_user_session_path
      end
      it 'get a alert message(アカウント登録もしくはログインしてください)' do
        subject
        expect(flash[:alert]).to eq('アカウント登録もしくはログインしてください。')
      end
    end
  end

  describe 'patch registrations#update (update user details)' do
    before { sign_in user }
    context 'valid information' do
      subject { patch user_registration_path, params: { user: { name:  'Edit User',
                                                                email: 'edit@example.com',
                                                                current_password: user.password } } }
      it 'redirect to root_path' do
        is_expected.to redirect_to root_path
      end
      it "update user.name from 'Test Tarou' to 'Edit User'" do
        subject
        expect(user.reload.name).to eq "Edit User"
      end
      it 'has been sent one email' do
        expect{ subject }.to change(ActionMailer::Base.deliveries, :count).by(1)
      end
    end
    context 'invalid information' do
      subject { patch user_registration_path, params: { user: { name:  ' ',
                                                                email: ' ',
                                                                current_password: user.password } } }
      it 'render :edit' do
        is_expected.to render_template :edit
      end
      it "cannot update user.name from 'Test Tarou' to ' '" do
        subject
        expect(user.reload.name).to eq 'Test Tarou'
      end
      it 'has not been sent one email' do
        expect{ subject }.to change(ActionMailer::Base.deliveries, :count).by(0)
      end
    end
  end

  describe '#logout' do
    before { sign_in user }
    subject { delete destroy_user_session_path }
    it 'redirect to root_path' do
      is_expected.to redirect_to root_path
    end
    it 'get a notice message（ログアウトしました。)' do
      subject
      expect(flash[:notice]).to eq('ログアウトしました。')
    end
  end

  describe '#delete' do
  end
end