# -*- encoding : utf-8 -*-

require File::expand_path('../../spec_helper', __FILE__)
require 'capybara/rspec'

describe UsersController do

  it "doesn't allow passwords shorter than 5 characters" do
    User.delete_all
    Identity.delete_all
    visit new_identity_path
    fill_in "name", with: "Shorty"
    fill_in "password", with: "1234"
    fill_in "password_confirmation", with: "1234"
    click_button "Register"
    page.should have_content "Passwordis too short (minimum is 5 characters)"
    fill_in "password", with: "12345"
    click_button "Register"
    page.should_not have_content "Prohibited this account from being saved"
  end
  
  describe "With an admin and temporary users" do
    before(:each) do
      User.delete_all
      Identity.delete_all
      visit root_path
      visit switch_language_path(:en)
      test_user 'Testuser', 'notsecret', "Admin"
    end
   
    it "should login user" do
      sign_in_user name: 'Testuser', password: 'notsecret'
      visit users_path
      page.should have_content "testuser@example.com"
      page.click_link "Edit"
      page.should have_content "testuser@example.com"
    end
  
    it "should have add- and remove authentication buttons" do
      sign_in_user name: 'Testuser', password: 'notsecret'
      visit "/users/testuser"
      page.should have_link "Twitter"
      page.should have_link "Facebook"
      page.should have_link "Remove"
    end
  
    it "should have a delete-button" do
      sign_in_user name: 'Testuser', password: 'notsecret'
      visit users_path
      page.should have_link "Cancel Account" 
      visit "/users/testuser"
      page.should have_link "Cancel Account" 
    end
  
    it "should delete user and creates a Event to AdminTimeline" do
      $NO_TIMELINE_FOR_SPECS = false
      @user1 = sign_in_user name: 'Testuser', password: 'notsecret'
      visit users_path
      page.click_link "Cancel Account" 
      visit users_path
      page.should have_no_content "testuser@example.com"
      # has created a UserChangedEvent to AdminTimeline
      Timeline.find_by(name: 'Admin').timeline_events.last.text.should =~ /User 'Testuser' was destroyed/
      $NO_TIMELINE_FOR_SPECS = true
    end

    it "should display a message if destroying is not possible" do
      class User
        before_destroy :prevent_destroying
        def prevent_destroying
          self.errors.add( :base, "I'll not die yet!")
          return false
        end
      end
      sign_in_user name: 'Testuser', password: 'notsecret'
      visit users_path
      page.click_link "Cancel Account" 
      page.should have_content "testuser@example.com"
      page.should have_content I18n.t(:can_not_delete_user, why: "I'll not die yet!")
    end
  
    it "shows facilities in user-show view" do
      sign_in_user name: 'Testuser', password: 'notsecret'
      visit user_path(User.first)
      page.should have_content "Facilities: Admin"
    end
  
    it "shows facilities and Google-map in user-list" do
      sign_in_user name: 'Testuser', password: 'notsecret'
      visit users_path
      page.should have_content "Facilities: Admin"
      page.should have_content "Your location: 51.4771,0" # (default if not set) Greenwich Park, London
      assert page.all( 'div', :class => 'user-location' ).count > 0, "Should show Google-map, but doesn't"
    end
  
    it "should not show foreign users unless current_user is admin" do
      visit signout_path
      test_user 'Foreigner', 'alians'
      test_user 'Hacker', 'notsecret'
      visit users_path
      page.should_not have_content "foreigner@example.com"
      page.should have_content "Access denied"
    end
  
    it "sends a confirmation mail when a user is created and creates a Event to AdminTimeline" do
      visit signout_path
      $NO_TIMELINE_FOR_SPECS = false
      sign_up_user name: "Friendly User", password: 'notsecret', email: 'friendly.user@example.com'
      last_email.to.should include('friendly.user@example.com')
      # has created a UserChangedEvent to AdminTimeline
      Timeline.find_by(name: 'Admin').timeline_events.last.text.should =~ /User 'Friendly User' was created/
      $NO_TIMELINE_FOR_SPECS = true
    end
  
    it "sends a confirmation mail when the email changes" do
      visit signout_path
      test_user 'New User', 'secret'
      sign_in_user name: 'New User', password: 'secret'
      click_link "Edit profile"
      click_link "Email & Location"
      fill_in "Email", with: "user1@iboard.cc"
      click_button "Save"
      last_email.to.should include('user1@iboard.cc')
    end
  
    it "checks email confirmed" do
      visit signout_path
      User.delete_all
      sign_up_user name: "Friendly User", password: 'notsecret', email: 'user@iboard.cc'
      user = User.first
      assert user.email_confirmed? == false, "email_confirmed? should be false"
      visit confirm_email_user_path(user,user.confirm_email_token)
      user.reload
      assert user.email_confirmed? == true, "email_confirmed? should be true after confirming it"
    end

    it "shows a message if user doesn't confirm their email yet" do
      visit signout_path
      User.delete_all
      sign_up_user name: "Friendly User", password: 'notsecret', email: 'user@iboard.cc'
      visit signout_path
      sign_in_user name: "Friendly User", password: 'notsecret'
      page.should have_content "Your email is not confirmed by now. Please check your mailbox for user@iboard.cc."
      page.should have_link "Resend confirmation mail"
    end
  
    it "adds an Identity to an existing user" do
      visit signout_path
      @twitteruser = User.create name: 'Twitter User', email: 'twitter@example.com'
      @twitteruser.authentications.create provider: "twitter", uid: "1345"
      set_current_user(@twitteruser)
      visit new_identity_path
      fill_in "password", with: "ABCdefg"
      fill_in "password_confirmation", with: "ABCdefg"
      click_button "Register"
      unset_current_user
      sign_in_user name: "Twitter User", password: 'ABCdefg'
      page.should have_content "Signed in"
    end

    it "adds a location to an existing user" do
      sign_in_user name: 'Testuser', password: 'notsecret'
      visit "/users/testuser/edit"
      page.should have_content "Location (lat,long)"
      page.should have_content "Search by address"
      fill_in "user[location_token]", with: "48.1572,14.0152"
      click_button("Save")
      page.should have_content "Your data has been updated successfully"
      click_link "Email & Location"
      assert page.find('#user_location_token').value == '48.1572,14.0152', "Location was not saved!"
    end

  end

  describe "For a standard user with identity" do

    before(:each) do
      User.delete_all
      Identity.delete_all
      visit signout_path
      visit switch_language_path(:en)
      @user1 = test_user 'Mr. Standard', 'Mr. Nice'
      sign_in_user name: 'Mr. Standard', password: 'Mr. Nice'
    end

    it "shows connected auth_providers" do
      visit user_path(@user1)
      page.should have_link "Assign authentication providers"
      page.should have_link "Personal information"
    end
  
    it "doesn't show Listing users unless user is admin" do
      visit user_path(@user1)
      page.should_not have_link "Listing Users"
    end

    it "supports forgot password" do
      user = test_user 'Fred Alzheimer', 'secret'
      visit signout_path

      # request a token for an existing email
      visit forgot_password_users_path
      fill_in "email", with: 'fred.alzheimer@example.com'
      click_button 'Send token'
      page.should have_content "Please check your inbox for address fred.alzheimer@example.com"

      # Parse last email for token
      @token = last_email.parts.first.body.to_s.gsub(/Reset token: ([\S|\-]+)\n/).first.gsub(/Reset token: /, '').strip
      @token.should_not be nil

      # Visit the reset password page and set new password
      visit reset_password_user_path(user,@token)
      fill_in 'Password', with: "dontforget"
      fill_in 'Password confirmation', with: "dontforget"
      click_button "Reset password"
      page.should have_content "New password set"

      # Check to login with new password
      sign_in_user name: "Fred Alzheimer", password: 'dontforget'
      page.should have_content "Signed in"
    end

    it "provides a forgot-password link on the sign-in-page" do
      visit signin_path
      page.should have_link 'Forgot password?'
    end


  end
  
  describe "as an admin" do
    before(:each) do
      User.delete_all
      Identity.delete_all
      visit switch_language_path(:en)
      @admin = test_user 'Admin', 'notsecret', 'Admin'
      @confirmed_at = @admin.email_confirmed_at
      sign_in_user name: 'Admin', password: 'notsecret'
    end

    it "shows the confirmation status in user::index" do
      visit users_path
      page.should have_content "Email confirmed at: #{I18n.localize(@confirmed_at)}"
      page.should have_content "Account exists since #{I18n.localize(@admin.created_at)}"
    end

    it "finds users using the search-form without JS" do
      test_user 'Hidden user', 'secret'
      visit users_path
      page.should have_content "admin@example.com"
      page.should have_content "hidden.user@example.com"
      fill_in 'search_search_text', with: "admi"
      click_button "Search"
      page.should have_content "admin@example.com"
      page.should_not have_content "hidden.user@example.com"
      assert page.all( '.user-location div' ).count == 0, "Should not show Google-map while search"
    end

    it "finds users using the search-form with JS", js: true do
      User.create name: "Find Me", email: "find@me.com"
      set_current_user @admin
      visit users_path
      fill_in 'search_search_text', with: "find"
      page.should_not have_button "Search"
      page.should have_content "find@me.com"
      page.should_not have_content "admin@example.com"
      assert page.all( '.user-location div' ).count == 0, "Should not show Google-map while search"
    end

  end

end
