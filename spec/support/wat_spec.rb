# wat's Spec Helper

def sign_up_user(options={})
  _name = options[:name]
  _password = options[:password]
  _email = options[:email]

  visit new_identity_path
  fill_in "Name", with: _name
  fill_in "Password", with: _password
  fill_in "Password confirmation", with: _password
  click_button "Register"
  page.should_not have_content "Prohibited this account from being saved"
  fill_in "Email", with: _email
  click_button "Save"
end

def sign_in_user(options={})
  visit signin_path
  fill_in "Name", with: options[:name]
  fill_in "Password", with: options[:password]
  click_button "Sign in"
end
