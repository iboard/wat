# -*- encoding : utf-8 -*-

require File::expand_path('../../spec_helper', __FILE__)
require 'capybara/rspec'

describe UsersController do

  before(:each) do
    User.delete_all
    Identity.delete_all
    @user1 = test_user 'Fritz Cat', 'secret'
    visit switch_language_path('en')
    sign_in_user name: 'Fritz Cat', password: 'secret'
  end

  it "switches personal information and authentication providers", js: true do
    visit user_path(@user1)
    click_link 'Personal information'
    page.should have_content "Your profile"
    click_link 'Assign authentication providers'
    page.should have_content "Identity"
  end

  it "displays a 'create profile' if no profile exist yet", js: true do
    visit user_path(@user1)
    click_link 'Personal information'
    page.should have_link "Create your profile"
  end

  it "offers a form to create the profile", js: true do
    visit user_path(@user1)
    click_link 'Personal information'
    click_link "Create your profile"
    fill_in 'Phone number', with: '+43 1234 5678'
    click_button "Save"
    page.should have_content "Profile successfully updated"
    page.should have_content "+43 1234 5678"
  end

  it "deletes the profile", js: true do
    visit user_path(@user1)
    click_link 'Personal information'
    click_link "Create your profile"
    fill_in 'Phone number', with: '+43 1234 5678'
    click_button "Save"
    page.should have_content "Profile successfully updated"

    click_link "Delete"
    page.should have_link "Create your profile"
  end

  it "saves changes in the profile", js: true do
    visit user_path(@user1)
    click_link 'Personal information'
    click_link "Create your profile"
    fill_in 'Phone number', with: '+43 1234 5678'
    click_button "Save"
    page.should have_content "Profile successfully updated"
    page.all("a", text:'Edit').last.click()
    fill_in "profile_firstname", with: "Eduard"
    fill_in "profile_lastname", with: "Nockenfell"
    click_button "Save"
    page.should have_content "Profile successfully updated"
    page.should have_content "Eduard"
    page.should have_content "Nockenfell"
  end

  it "shows an avatar in user header", js: true do
    visit user_path(@user1)
    click_link 'Personal information'
    click_link "Create your profile"
    check "Use gravatar"
    click_button "Save"
    page.should have_content "Profile successfully updated"
    visit user_path(@user1)
    page.body.should match "http://gravatar.com/avatar/"
  end

end
