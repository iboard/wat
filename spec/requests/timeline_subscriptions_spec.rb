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
    visit switch_language_path(:en)
    sign_in_user name: 'Frank Zappa', password: 'secretword'
  end

  it "should renders timeline events and timeline-subscriptions" do
    visit timelines_path
    page.should have_content "Timeline"
  end

  describe UserEvent do
    it "allows to post via HTML/POST to 'doorkeeper'-Timeline WITHOUT JS" do
      fill_in "timeline_event_timeline_event_message", with: "My first posting to public Timeline"
      click_button "Post"
      Doorkeeper.latest_event.text.should =~ /Frank Zappa says, 'My first posting to public Timeline'/
      page.should have_content "Frank Zappa says, 'My first posting to public Timeline'"
    end

    it "allows to post via HTML/POST to 'doorkeeper'-timeline with JS", js: true do
      fill_in "timeline_event_timeline_event_message", with: "My first posting to public Timeline"
      click_button "Post"
      wait_until {  Doorkeeper::timeline.reload.timeline_events.map(&:text).join(" ") =~ /Frank Zappa says/ }
      Doorkeeper.latest_event.text.should =~ /Frank Zappa says, 'My first posting to public Timeline'/
    end
  end

  describe TimelineSubscription do
    it "Renders a list of available timelines on right box" do
      visit timelines_path
      page.should have_content "Subscriptions"
      page.should have_content "Doorkeeper"
      page.should have_content "User-posts-frank-zapp"
    end

    it "allows to change the subscription by clicking the checkbox on/off", js: true do
      u=User.first
      u.timeline_subscriptions.delete_all
      u.save

      visit timelines_path
      check "timeline_subscriptions_message_#{Timeline.where(name: 'doorkeeper').first._id}"
      wait_until { page.has_content? "You're now receiving messages from 'doorkeeper'"}
      page.should have_content "You're now receiving messages from 'doorkeeper'"
      page.should have_content "Frank Zappa signed in"

      uncheck "timeline_subscriptions_message_#{Timeline.where(name: 'doorkeeper').first._id}"
      wait_until { page.has_content? "You will not receive new messages from 'doorkeeper'"}
      page.should have_content "You will not receive new messages from 'doorkeeper'"
      page.should_not have_content "Frank Zappa signed in"
    end
  end
end