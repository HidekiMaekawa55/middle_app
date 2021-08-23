require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let(:user) { create(:user) }
  let(:user_last) { User.last }
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
    subject { post user_registration_path, params: { user: user_type } }
    context 'valid information' do
      let(:user_type) { user_params }
      it 'redirect to root_path' do
        is_expected.to redirect_to root_path
      end
      it 'the number of users increases by 1' do
        expect{ subject }.to change(User, :count).by(1)
      end
      it 'has been sent one email' do
        expect{ subject }.to change(ActionMailer::Base.deliveries, :count).by(1)
      end
      context 'email transmission content' do
        before { subject }
        let(:mail) { ActionMailer::Base.deliveries.last }
        it "email subject is 'メールアドレス確認メール'" do
          expect(mail.subject).to eq "メールアドレス確認メール"
        end
        it 'mail to user.email' do
          expect(mail.to).to eq [user_last.email]
        end
        it "mail from to 'njs.20598@gmail.com'" do
          expect(mail.from).to eq ["njs.20598@gmail.com"]
        end
        it 'mail body contains user.email' do
          expect(mail.body.encoded).to match user_last.email
        end
        it 'mail body contains user.confirmation_token' do
          expect(mail.body.encoded).to match user_last.confirmation_token
        end
      end
    end
    context 'invalid information' do
      let(:user_type) { invalid_user_params }
      it 'render :new' do
        is_expected.to render_template :new
      end
      it 'the number of users no change' do
        expect{ subject }.to change(User, :count).by(0)
      end
      it 'has not been sent one email' do
        expect{ subject }.to change(ActionMailer::Base.deliveries, :count).by(0)
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
    subject { post user_session_path, params: { user: { email:    user_email, 
                                                        password: user_password } } }
    context 'valid information' do
      let(:user_email)    { user.email }
      let(:user_password) { user.password }
      it 'request succeds' do
        is_expected.to redirect_to root_path
      end
      it 'get a notice message (ログインしました。)' do
        subject
        expect(flash[:notice]).to eq('ログインしました。')
      end
    end
    context 'invalid information' do
      let(:user_email)    { "invalid" }
      let(:user_password) { "invalid"}
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
    subject { get edit_user_registration_path }
    context 'when user logged in' do
      before { sign_in user }
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
    subject { patch user_registration_path, params: { user: {
                                           name:             user_name,
                                           email:            user_email,
                                           current_password: user_password } } }
    before { sign_in user }
    context 'valid information' do
      let(:user_name)     { 'Edit User' }
      let(:user_email)    { 'edit@example.com' }
      let(:user_password) { user.password }
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
      context 'email transmission content' do
        before { subject }
        let(:mail) { ActionMailer::Base.deliveries.last }
        it "email subject is 'メールアドレス確認メール'" do
          expect(mail.subject).to eq "メールアドレス確認メール"
        end
        it "mail to  user's new email address" do
          expect(mail.to).to eq ['edit@example.com']
        end
        it "mail from to 'njs.20598@gmail.com'" do
          expect(mail.from).to eq ["njs.20598@gmail.com"]
        end
        it "mail body contains user's new email address" do
          expect(mail.body.encoded).to match 'edit@example.com'
        end
        it 'mail body contains user.reload.confirmation_token' do
          expect(mail.body.encoded).to match user.reload.confirmation_token
        end
      end
    end
    context 'invalid information' do
      let(:user_name)     { 'Edit User' }
      let(:user_email)    { 'edit@example.com' }
      let(:user_password) { 'invalid' }
      it 'render :edit' do
        is_expected.to render_template :edit
      end
      it "cannot update user.name from 'Test Tarou' to 'Edit User'" do
        subject
        expect(user.reload.name).to eq 'Test Tarou'
      end
      it 'has not been sent one email' do
        expect{ subject }.to change(ActionMailer::Base.deliveries, :count).by(0)
      end
    end
  end

  describe '#logout' do
    subject { delete destroy_user_session_path }
    before { sign_in user }
    it 'redirect to root_path' do
      is_expected.to redirect_to root_path
    end
    it 'get a notice message（ログアウトしました。)' do
      subject
      expect(flash[:notice]).to eq('ログアウトしました。')
    end
  end

  describe 'get passwords#new（if forget password）' do
    subject { get new_user_password_path }
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

  describe 'post passwords#create（if forget password）' do
    subject { post user_password_path, params: { user: { email: user_email } } }
    context 'valid information' do
      let(:user_email) { user.email }
      it "redirect to 'users/sign_in'" do
        is_expected.to redirect_to new_user_session_path
      end
      it 'get a notice message' do
        subject
        expect(flash[:notice]).to be_truthy
      end
      it 'has been sent one email' do
        expect{ subject }.to change(ActionMailer::Base.deliveries, :count).by(1)
      end
      context 'email transmission content' do
        before { subject }
        let(:mail) { ActionMailer::Base.deliveries.last }
        it "email subject is 'パスワードの再設定について'" do
          expect(mail.subject).to eq "パスワードの再設定について"
        end
        it "mail to  user's email address" do
          expect(mail.to).to eq [user.email]
        end
        it "mail from to 'njs.20598@gmail.com'" do
          expect(mail.from).to eq ["njs.20598@gmail.com"]
        end
        it "mail body contains user's email address" do
          expect(mail.body.encoded).to match user.email
        end
      end
    end
    context 'invalid information' do
      context 'invalid email address' do
        let(:user_email) { "invalid@exmaple.com" }
        it 'render :new' do
          is_expected.to render_template :new
        end
        it 'has not been sent email' do
          expect{ subject }.to change(ActionMailer::Base.deliveries, :count).by(0)
        end
      end
    end
  end
end