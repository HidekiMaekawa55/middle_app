require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let(:user) { create(:user) }
  let(:user_last) { User.last }
  let(:user_params) { attributes_for(:user) }
  let(:invalid_user_params) { attributes_for(:user, email: " " )}

  shared_examples :success_request do |template_name|
    it { is_expected.to eq 200 }
    it { is_expected.to render_template(template_name) }
  end
  shared_examples :redirect_to_root_path do
    it { is_expected.to redirect_to root_path }
  end
  shared_examples :redirect_to_sign_in_page do
    it { is_expected.to redirect_to new_user_session_path }
  end

  describe 'get #sign_up' do
    subject { get new_user_registration_path }
    context 'when user logged in' do
      before { sign_in user }
      it_behaves_like :redirect_to_root_path
    end
    context 'when user not logged in' do
      it_behaves_like :success_request, :new
    end
  end

  describe 'post registrations#create (sign up)' do
    subject { post user_registration_path, params: { user: information } }
    context 'valid information' do
      let(:information) { user_params }
      it_behaves_like :redirect_to_root_path
      it { expect{ subject }.to change(User, :count).by(1) }
      it { expect{ subject }.to change(ActionMailer::Base.deliveries, :count).by(1) }
      context 'email transmission content' do
        before { subject }
        let(:mail) { ActionMailer::Base.deliveries.last }
        it { expect(mail.subject).to eq "メールアドレス確認メール" }
        it { expect(mail.to).to eq   [user_last.email] }
        it { expect(mail.from).to eq ["njs.20598@gmail.com"] }
        it { expect(mail.body.encoded).to match user_last.email }
        it { expect(mail.body.encoded).to match user_last.confirmation_token }
      end
    end
    context 'invalid information' do
      let(:information) { invalid_user_params }
      it { is_expected.to render_template :new }
      it { expect{ subject }.to change(User, :count).by(0) }
      it { expect{ subject }.to change(ActionMailer::Base.deliveries, :count).by(0) }
    end
  end

  describe 'get #sign_in' do
    subject { get new_user_session_path }
    context 'when user logged in' do
      before { sign_in user }
      it_behaves_like :redirect_to_root_path
    end
    context 'when user not logged in' do
      it_behaves_like :success_request, :new
    end
  end

  describe 'post sessions#create (sign in)' do
    subject { post user_session_path, params: { user: { email:    user_email, 
                                                        password: user_password } } }
    context 'valid information' do
      let(:user_email)    { user.email }
      let(:user_password) { user.password }
      it_behaves_like :redirect_to_root_path
      it do
        subject
        expect(flash[:notice]).to eq('ログインしました。')
      end
    end
    context 'invalid information' do
      let(:user_email)    { "invalid" }
      let(:user_password) { "invalid"}
      it { is_expected.to render_template :new }
    end
  end

  describe 'get #edit' do
    subject { get edit_user_registration_path }
    context 'when user logged in' do
      before { sign_in user }
      it_behaves_like :success_request, :edit
    end
    context 'when user not logged in' do
      it_behaves_like :redirect_to_sign_in_page
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
      it_behaves_like :redirect_to_root_path
      it  do
        subject
        expect(user.reload.name).to eq "Edit User"
      end
      it { expect{ subject }.to change(ActionMailer::Base.deliveries, :count).by(1) }
      context 'email transmission content' do
        before { subject }
        let(:mail) { ActionMailer::Base.deliveries.last }
        it { expect(mail.subject).to eq "メールアドレス確認メール" }
        it { expect(mail.to).to eq   ['edit@example.com'] }
        it { expect(mail.from).to eq ["njs.20598@gmail.com"] }
        it { expect(mail.body.encoded).to match 'edit@example.com' }
        it { expect(mail.body.encoded).to match user.reload.confirmation_token }
      end
    end
    context 'invalid information' do
      let(:user_name)     { 'Edit User' }
      let(:user_email)    { 'edit@example.com' }
      let(:user_password) { 'invalid' }
      it { is_expected.to render_template :edit }
      it do
        subject
        expect(user.reload.name).to_not eq 'Edit User'
      end
      it { expect{ subject }.to change(ActionMailer::Base.deliveries, :count).by(0) }
    end
  end

  describe '#logout' do
    subject { delete destroy_user_session_path }
    before { sign_in user }
    it_behaves_like :redirect_to_root_path
    it do
      subject
      expect(flash[:notice]).to eq('ログアウトしました。')
    end
  end

  describe 'get passwords#new（if forget password）' do
    subject { get new_user_password_path }
    context 'when user logged in' do
      before { sign_in user }
      it_behaves_like :redirect_to_root_path
    end
    context 'when user not logged in' do
      it_behaves_like :success_request, :new
    end
  end 

  describe 'post passwords#create（if forget password）' do
    subject { post user_password_path, params: { user: { email: user_email } } }
    context 'valid information' do
      let(:user_email) { user.email }
      it_behaves_like :redirect_to_sign_in_page
      it { expect{ subject }.to change(ActionMailer::Base.deliveries, :count).by(1) }
      context 'email transmission content' do
        before { subject }
        let(:mail) { ActionMailer::Base.deliveries.last }
        it { expect(mail.subject).to eq "パスワードの再設定について" }
        it { expect(mail.to).to eq   [user.email] }
        it { expect(mail.from).to eq ["njs.20598@gmail.com"] }
        it { expect(mail.body.encoded).to match user.email }
      end
    end
    context 'invalid information' do
      context 'invalid email address' do
        let(:user_email) { "invalid@exmaple.com" }
        it { is_expected.to render_template :new }
        it { expect{ subject }.to change(ActionMailer::Base.deliveries, :count).by(0) }
      end
    end
  end
end