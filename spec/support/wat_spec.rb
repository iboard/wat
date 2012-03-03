# wat's Spec Helper

def sign_up_user(options={})
  _name = options[:name]
  _password = options[:password]
  _email = options[:email]

  visit new_identity_path
  page.fill_in "Name", with: _name
  page.fill_in "Password", with: _password
  page.fill_in "Password confirmation", with: _password
  page.click_button "Register"
  page.should_not have_content "Prohibited this account from being saved"
  page.fill_in "Email", with: _email
  page.click_button "Save"
end

def sign_in_user(options={})
  visit signin_path
  page.fill_in "Name", with: options[:name]
  page.fill_in "Password", with: options[:password]
  page.click_button "Log in"
end
