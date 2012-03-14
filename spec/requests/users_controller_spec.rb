# -*- encoding : utf-8 -*-

require File::expand_path('../../spec_helper', __FILE__)
require 'capybara/rspec'

describe UsersController do
  
  before(:each) do
    User.delete_all
    Identity.delete_all
    sign_up_user name: 'Testuser', password: 'notsecret', email: 'test@iboard.cc'    
    User.first.facilities.create name: 'Admin', access: 'rwx'
  end
 
  it "should login user" do
     sign_in_user name: 'Testuser', password: 'notsecret'
     visit users_path
     page.click_link "You –> Edit"
     page.should have_content "Testuser"
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

  it "should delete user" do
    sign_in_user name: 'Testuser', password: 'notsecret'
    visit users_path
    page.click_link "Cancel Account" 
    visit users_path
    page.should have_no_content "Testuser"
  end

  it "shows facilities in user-show view" do
    User.first.facilities.create name: 'Admin', access: 'rwx'
    sign_in_user name: 'Testuser', password: 'notsecret'
    visit user_path(User.first)
    page.should have_content "Facilities: Admin"
  end

  it "shows facilities in user-list" do
    User.first.facilities.find_or_create_by name: 'Admin', access: 'rwx'
    sign_in_user name: 'Testuser', password: 'notsecret'
    visit users_path
    page.should have_content "Facilities: Admin"
  end

  it "should not show foreign users unless current_user is admin" do
    visit signout_path
    User.create  name: 'Foreigner', email: 'alien@iboard.cc'
    sign_up_user name: 'Hacker', password: 'notsecret', email: 'hacked@iboard.cc'    
    visit users_path
    page.should_not have_content "Foreigner"
    page.should have_content "Access denied"
  end

end
