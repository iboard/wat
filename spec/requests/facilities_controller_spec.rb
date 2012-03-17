require 'spec_helper'

describe FacilitiesController do

  before(:each) do
    User.delete_all
    Identity.delete_all
    sign_up_user name: 'Admin', password: 'notsecret', email: 'admin@iboard.cc'
    @admin = User.first
    @admin.email_confirmed_at = Time.now
    @admin.facilities.find_or_create_by name: 'Admin', access: 'rwx'
    @admin.save!
    @user1 = User.create name: 'User One', email: 'usr1@iboard.cc', email_confirmed_at: Time.now
    @user2 = User.create name: 'User Two', email: 'usr2@iboard.cc', email_confirmed_at: Time.now
  end

  it "offers an edit-facility-button for any user if you're an admin" do
    sign_in_user name: 'Testuser', password: 'notsecret'
    visit users_path
    assert page.find("##{@user1.id.to_s}-edit-button"), "There should be an edit-button for each user"
  end

  it "lists user's facilites" do
    sign_in_user name: 'Testuser', password: 'notsecret'
    @user1.facilities.create(name: 'Testfacility', access: 'rwx')
    visit users_path
    page.find("##{@user1.id.to_s}-edit-button").find('a').click
    page.should have_content "Edit facilities for user 'User One'"
    page.should have_content "Testfacility (rwx)"
    assert page.find("##{@user1.facilities.first.id.to_s}-remove-button"), "Facility should have a remove-button"
  end

  it "removes facility from user with remove-button" do
    sign_in_user name: 'Testuser', password: 'notsecret'
    @user1.facilities.create(name: 'Testfacility', access: 'rwx')
    visit user_facilities_path(@user1)
    page.should have_content "Testfacility (rwx)"
    page.find("##{@user1.facilities.first.id.to_s}-remove-button").find('a').click
    page.should_not have_content "Testfacility"
  end

  it "has a form for a new facility" do
    sign_in_user name: 'Testuser', password: 'notsecret'
    visit user_facilities_path(@user1)
    select "Admin", from: "Name"
    check 'read'
    uncheck 'write'
    check 'execute'
    click_button "Add Facility"
    page.should have_content 'Facility successfully added'
    page.should have_content 'Admin'
    page.should have_content 'r-x'
  end

  it "shows 'no facilites yet' if user has no" do
    sign_in_user name: 'Testuser', password: 'notsecret'
    visit user_facilities_path(@user2)
    page.should have_content "User has no facilities defined yet" 
  end
  

end
