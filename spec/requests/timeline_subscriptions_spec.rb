# -*- encoding : utf-8 -*-"
#
# Created by Andi Altendorfer <andreas@altendorfer.at>, 20.08.12, 12:58
#
#
require "rspec"

describe TimelineSubscriptionsController do

  before(:each) do
    Timeline.delete_all
    User.delete_all
    Identity.delete_all
    @user = test_user 'Frank Zappa', 'secretword'
    @user.subscribe_timelines(@user.timeline)
    visit switch_language_path(:en)
    sign_in_user name: 'Frank Zappa', password: 'secretword'
  end

  it "should render timeline events and timeline-subscriptions" do
    visit timelines_path
    page.should have_content "Timeline"
  end

  describe UserEvent do
    it "allows to post via HTML/POST to 'doorkeeper'-Timeline WITHOUT JS" do
      fill_in "timeline_event_timeline_event_message", with: "My first posting to public Timeline"
      click_button "Post"
      @user.timeline.reload.timeline_events.last.text.should == "<span class='timestamp-timeline'>less than a minute ago,</span> <span class='timeline-username'>[Frank Zappa](/users/frank-zappa/profile) says</span><br/><span class='timeline-message'>'My first posting to public Timeline'</span>"
      page.text.should match /Frank Zappa.*says.*'My first posting to public Timeline'/
    end

    it "allows to post via HTML/POST to 'doorkeeper'-timeline with JS", js: true do
      fill_in "timeline_event_timeline_event_message", with: "My first posting to public Timeline"
      click_button "Post"
      wait_until { @user.timeline && @user.timeline.reload.timeline_events.map(&:text).join(" ") =~ /Frank Zappa.*says/ }
      @user.timeline.timeline_events.last.text.should == "<span class='timestamp-timeline'>less than a minute ago,</span> <span class='timeline-username'>[Frank Zappa](/users/frank-zappa/profile) says</span><br/><span class='timeline-message'>'My first posting to public Timeline'</span>"
    end
  end

  describe "Personal Timeline" do

    it "Renders a list of available timelines on right box" do
      visit timelines_path
      page.should have_content "Subscriptions"
      page.should have_content "Doorkeeper"
      page.should have_content "Frank Zappa"
    end

    it "shows an edit-box for own timeline" do
      visit timelines_path
      page.should have_content "Personal Timeline"
    end

  end

  describe TimelineSubscription do

    it "doesn't list disabled or non-public timelines" do
      other_user = test_user "Mr. Nowhere", "secret"
      other_user.timeline.update_attributes(public: false)
      Timeline.create( name: 'Disabled Timeline', enabled: false )
      visit timelines_path
      page.find("#timeline_subscriptions_message_#{@user.timeline._id}").should_not be_nil
      page.find("#timeline_subscriptions_message_#{doorkeeper_timeline._id}").should_not be_nil
      page.should_not have_content "Mr. Nowhere"
      page.should_not have_content "Disabled Timeline"
    end

    it "allows to change the subscription by clicking the checkbox on/off", js: true do
      u=User.first
      u.timeline_subscriptions.delete_all
      u.save

      visit timelines_path
      check "timeline_subscriptions_message_#{Timeline.where(name: 'doorkeeper').first._id}"
      wait_until { page.has_content? "You're now receiving messages from 'doorkeeper'"}
      page.should have_content "You're now receiving messages from 'doorkeeper'"
      page.text.should match /Frank Zappa.*signed in/

      uncheck "timeline_subscriptions_message_#{Timeline.where(name: 'doorkeeper').first._id}"
      wait_until { page.has_content? "You will not receive new messages from 'doorkeeper'"}
      page.should have_content "You will not receive new messages from 'doorkeeper'"
      page.text.should_not match /Frank Zappa.*signed in/
    end

  end
end