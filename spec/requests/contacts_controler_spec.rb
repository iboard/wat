# -*- encoding : utf-8 -*-

require File::expand_path('../../spec_helper', __FILE__)
require 'capybara/rspec'

describe ContactsController do

  before(:each) do
    User.delete_all
    Identity.delete_all
    visit switch_language_path(:en)
    @admin = test_user 'Fredy', 'notsecret', 'User'
    sign_in_user name: 'Fredy', password: 'notsecret'
  end

  it "User menu has a link to 'Contacts'" do
    page.should have_link "Contacts"
  end

  describe "Contacts index of current user with friends" do
    before(:each) do
      [1,2,3].each do |n|
        test_user "Friend #{n}", "secret"
      end
      test_user "Asshole", "secret"
      f = @admin.facilities.create(name: 'Friends', access: 'r--')
      f.add_consumers( User.where(name: /Friend /))
      @admin.save!
    end

    it "lists Friend 1..3 but not the 'Asshole'" do
      visit contacts_path
      [1,2,3].each do |n|
        page.should have_content "Friend #{n}"
      end
      page.should_not have_content "Asshole"
    end

    it "shows an add-contact button on /contacts" do
      @admin.facilities.where(name: 'Friends').delete_all
      visit contacts_path
      page.should have_link I18n.t(:invite_contact)
      page.should have_content I18n.t(:invate_contact_hint_if_no_contacts_exists)
    end

    it "can delete a contact-facility" do
      visit contacts_path
      page.should have_link "delete-facility-friend-1"
      click_link "delete-facility-friend-1"
      page.should have_content I18n.t(:contact_removed, user: 'Friend 1')
      page.should_not have_link "delete-facility-friend-1"
    end
  end

end
