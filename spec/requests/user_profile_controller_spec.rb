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

  it "shows an default avatar in user header if no image is available" do
    visit user_path(@user1)
    page.should have_css(".avatar")
  end

  it "shows an avatar in user header", js: true do
    visit user_path(@user1)
    click_link 'Avatar'
    check "Use gravatar"
    click_button "Update avatar"
    visit user_path(@user1)
    page.body.should match "http://gravatar.com/avatar/"
  end

  describe "Local Avatar" do
    before(:each) do
      visit user_path(@user1)
      click_link "Avatar"
    end

    it "shows an avatar-upload form", js: true do
      page.should have_content "Upload your avatar"
    end

    it "uploads a file", js: true do
      avatar_file = File.join(::Rails.root, "fixtures/avatar.jpg") 
      attach_file("avatar_avatar", avatar_file)
      click_button("Update avatar")
      page.should have_content "Crop"
      click_button "Crop"
      @user1.reload
      page.all('img', src: @user1.avatar.avatar.path(:tiny) ).first.should_not be_nil
    end

    it "offers a crop avatar form", js: true do
      avatar_file = File.join(::Rails.root, "fixtures/avatar.jpg") 
      attach_file("avatar_avatar", avatar_file)
      click_button("Update avatar")
      page.should have_content "Crop"
      click_button "Crop"
      @user1.reload
      page.all('img', src: @user1.avatar.avatar.path(:tiny) ).first.should_not be_nil
    end

  end

  describe "Public Profile" do
    before(:each) do
      @user1.profile.delete if @user1.profile
      @user1.create_profile(firstname: 'Fritz', lastname: 'Cat', dob: DateTime.parse("1964-08-31 06:00"),
                            phone_number: '+43 123 4567890', mobile: '+43 699 0987654321', twitter_handle: '@nickendell',
                            facebook_profile: 'fritz.the.cat', google_uid: '1234567890ABCDEFGH'
      )
    end

    it "shows the user' profile" do
      visit user_profile_path(@user1)
      page.should have_content "Fritz"
      page.should have_content "Cat"
      page.should have_content "+43 123 4567890"
      page.should have_content "+43 699 0987654321"
      page.should have_link "Twitter"
      page.should have_link "Facebook"
      page.should have_link "Google+"
    end

    it "checks show_public_flag" do
      @user1.profile.is_public=false
      @user1.save!
      visit signout_path
      visit user_profile_path(@user1)
      page.should have_content "This profile is not public"
    end

    it "shows a 'No Profile' page if user.profile == nil" do
      test_user "No Profile", "secret"
      visit "/users/no-profile/profile"
      page.should have_content "User 'No Profile' doesn't have a (public) profile-page."
    end
  end
end
