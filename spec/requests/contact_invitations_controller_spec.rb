# -*- encoding : utf-8 -*-

require File::expand_path('../../spec_helper', __FILE__)
require 'capybara/rspec'

describe ContactInvitationsController do

  before(:each) do
    User.delete_all
    Identity.delete_all
    visit switch_language_path(:en)
    @admin = test_user 'Fredy', 'notsecret', 'User'
    sign_in_user name: 'Fredy', password: 'notsecret'
  end

  describe "Invite a contact" do
  
    before(:each) do
      [1,2,3].each do |n|
        test_user "Friend #{n}", "secret"
      end
      test_user "Asshole", "secret"
      f = @admin.facilities.create(name: 'Friends', access: 'r--')
      f.add_consumers( User.where(name: /Friend /))
      @admin.save!
      sign_in_user name: 'Fredy', password: 'notsecret'
      visit contacts_path
    end

    it "by sending an invitation" do
      click_link I18n.t(:invite_contact)
      page.should have_content I18n.t(:invate_contact_hint_if_no_contacts_exists)
      test_user "New Friend", "secret"
      fill_in :email, with: 'new.friend@example.com'
      click_button I18n.t(:send_invitation)
      _token = ""
      last_email.parts.first.body.to_s.gsub(/(accept_contact_invitation\/)([0-9a-fA-F]{20})/ ) do |args|
        _token = args.split(/\//).last
      end
      _token.length.should == 20
      page.should have_content I18n.t(:contact_invitation_sent, email: 'new.friend@example.com')
    end
  end

  describe "Accept an invitation" do
  
    before(:each) do
      @user = test_user "New Friend", "secret"
      sign_in_user name: 'New Friend', password: 'secret'
      invitation = ContactInvitation.create(sender: @admin, recipient_email: 'new.friend@example.com')
      @token = invitation.token
    end

    it "by visiting accept_contact_invitation_path and creates a UserEvent to sender's timeline" do
      visit accept_contact_invitation_path(@token)
      page.should have_content I18n.t(:your_account_is_now_connected_with, sender: 'Fredy' )
      # and has created a UserEvent to sender's timeline
      Timeline.find_by(name: @admin.name).timeline_events.last.message.should =~ /has_accepted_invitation/
    end

  end

end
