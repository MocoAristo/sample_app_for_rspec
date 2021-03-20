module Login_Support
  def login_user
    visit '/login'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'password'
    click_button 'Login'
  end
end
