require 'rails_helper'

RSpec.describe 'Users', type: :system do
  include Login_Support
  describe 'ログイン前' do
    describe 'ユーザー新規登録' do
      context 'フォームの入力値が正常' do
        before do
          visit '/sign_up'
        end
        it 'ユーザーの新規作成が成功する' do
          expect {
            fill_in 'Email', with: 'example@example.com'
            fill_in 'Password', with: '12345678'
            fill_in 'Password confirmation', with: '12345678'
            click_button 'SignUp'
          }.to change { User.count }.by(1)
          expect(page).to have_content('User was successfully created.'), 'フラッシュメッセージ「User was successfully created.」が表示されていません'
        end
      end


      context 'メールアドレスが未入力' do
        before do
          visit '/sign_up'
        end
        it 'ユーザーの新規作成が失敗する' do
          expect {
            fill_in 'Email', with: ''
            fill_in 'Password', with: '12345678'
            fill_in 'Password confirmation', with: '12345678'
            click_button 'SignUp'
          }.to change { User.count }.by(0)
          expect(page).to have_content("can't be blank")
        end
      end

      context '登録済のメールアドレスを使用' do
        before do
          visit '/sign_up'
        end
        it 'ユーザーの新規作成が失敗する' do
          user =  create(:user)
          expect {
            fill_in 'Email', with: user.email
            fill_in 'Password', with: '12345678'
            fill_in 'Password confirmation', with: '12345678'
            click_button 'SignUp'
          }.to change { User.count }.by(0)
          expect(page).to have_content("has already been taken")
        end
      end
    end

    describe 'マイページ' do
      context 'ログインしていない状態' do
        it 'マイページへのアクセスが失敗する' do
          visit '/login'
          fill_in 'Email', with: ''
          fill_in 'Password', with: ''
          click_button 'Login'
          expect(page).to have_content('Login failed')
        end
      end
    end
  end


  describe 'ログイン後' do
    let(:user) { create(:user) }
    describe 'ユーザー編集' do
      context 'フォームの入力値が正常' do
        it 'ユーザーの編集が成功する' do
          login_user
          visit "/users/#{user.id}/edit"
          fill_in 'Email', with: 'edit@example.com'
          fill_in 'Password', with: 'password'
          fill_in 'Password confirmation', with: 'password'
          click_button 'Update'
          expect(User.find(user.id).email).to eq('edit@example.com')
          expect(page).to have_content('User was successfully update')
        end
      end

      context 'メールアドレスが未入力' do
        it 'ユーザーの編集が失敗する' do
          login_user
          visit "/users/#{user.id}/edit"
          fill_in 'Email', with: ''
          fill_in 'Password', with: 'password'
          fill_in 'Password confirmation', with: 'password'
          click_button 'Update'
          expect(page).to have_content("can't be blank")
        end
      end

      context '登録済のメールアドレスを使用' do
        it 'ユーザーの編集が失敗する' do
          login_user
          user_duplicte_email = create(:user, email: 'user_duplicate@exmample.com')
          visit "/users/#{user.id}/edit"
          fill_in 'Email', with: user_duplicte_email.email
          fill_in 'Password', with: 'password'
          fill_in 'Password confirmation', with: 'password'
          click_button 'Update'
          expect(page).to have_content("has already been taken")
        end
      end

      context '他ユーザーの編集ページにアクセス' do
        it '編集ページへのアクセスが失敗する' do
          login_user
          another_user = create(:user)
          visit "/users/#{another_user.id}/edit"
          expect(page).to have_content("Forbidden access.")
        end
      end

      describe 'マイページ' do
        context 'タスクを作成' do
          it '新規作成したタスクが表示される' do
            login_user
            another_user = create(:user)
            visit "/tasks/new"
            expect {
              fill_in 'Title', with: 'title'
              fill_in 'Content', with: 'content'
              click_button 'Create Task'
            }.to change { Task.count }.by(1)
            expect(page).to have_content("Task was successfully created.")
          end
        end
      end
    end
  end
end
