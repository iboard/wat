# wat's Spec Helper

def sign_up_user(options={})
  _name = options[:name]
  _password = options[:password]
  _email = options[:email]

  visit new_identity_path
  fill_in "name", with: _name
  fill_in "password", with: _password
  fill_in "password_confirmation", with: _password
  click_button "Register"
  page.should_not have_content "Prohibited this account from being saved"
  fill_in "user_email", with: _email
  click_button "Save"
end

def sign_in_user(options={})
  visit signin_path
  fill_in "Name", with: options[:name]
  fill_in "Password", with: options[:password]
  click_button "Sign in"
end

def set_current_user(user)
  $CURRENT_USER = user
end

def unset_current_user
  $CURRENT_USER = nil
end

def lorem_text
  %{
    Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor 
    incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud 
    exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure 
    dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. 
    Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit 
    anim id est laborum.
  }.strip
end

