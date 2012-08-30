require 'spec_helper'

describe TimelinesController do

  before(:each) do
    User.delete_all
    Identity.delete_all
    @user = test_user 'testuser', 'secret'
  end

  describe "General behavior" do

    it "logs user logins to 'doorkeeper' timeline" do
      sign_in_user name: 'testuser', password: 'secret'
      event = Doorkeeper.latest_event
      event.sender.should == @user
      event.text.should match /testuser.*less than a minute ago.*signed in/
      visit signout_path
    end

    it "logs user logouts to 'doorkeeper' timeline" do
      sign_in_user name: 'testuser', password: 'secret'
      visit root_path
      visit signout_path
      visit root_path
      event = Doorkeeper.latest_event
      event.sender.should == @user
      event.text.should =~ /testuser.*less than a minute ago/
      visit signout_path
    end

    it "shows logins on the timelines-path" do
      sign_in_user name: 'testuser', password: 'secret'
      event = Doorkeeper.latest_event
      event.sender.should == @user
      visit timelines_path
      event.text.should == "<span class='timeline-username'>[testuser](/users/testuser/profile)</span> <span class='timestamp-timeline'>less than a minute ago</span><br/><span class='timeline-message'>signed in</span>"
      page.text.should match /testuser.*less than a minute ago.*signed in/
      visit signout_path
    end

    it "shows notifications on any page" do
      sign_in_user name: 'testuser', password: 'secret'
      visit root_path
      page.text.should match /testuser.*less than a minute ago.*signed in/
    end

    it "offers a hide/show link", js: true do
      visit switch_language_path(:en)
      sign_in_user name: 'testuser', password: 'secret'
      page.text.should match /testuser.*less than a minute ago.*signed in/
      visit root_path
      click_link "Timeline"
      wait_until { page.all('#entries', :visible => false) }
      assert page.all('#entries', :visible => false) != nil, 'Timeline should be closed'
      click_link "Timeline"
      wait_until { page.all('#entries', :visible => true) }
      assert page.all('#entries', :visible => true) != nil, 'Timeline should be open'
    end

    it "allows a user to post messages", js: true do
      visit switch_language_path(:en)
      sign_in_user name: 'testuser', password: 'secret'
      fill_in "timeline_event[timeline_event][message]", with: "Hello World!"
      click_button "Post"
      wait_until {  @user.timeline.reload.timeline_events.map(&:text).join(" ") =~ /testuser.*says/ }
      @user.timeline.timeline_events.last.text.should == "<span class='timestamp-timeline'>less than a minute ago,</span> <span class='timeline-username'>[testuser](/users/testuser/profile) says</span><br/><span class='timeline-message'>'Hello World!'</span>"

    end

    it "groups messages if one occurs in multiple subscribed timelines" do
      %w(TimelineOne TimelineTwo).each do |tl|
        _tl = Timeline.create name: tl, public: true, enabled: true
        _tl.facilities.create name: "Poster", access: 'rwx'
        @user.subscribe_timelines(_tl)
      end
      @user.facilities.create name: "Poster", access: 'rwx'
      @user.reload
      sign_in_user name: 'testuser', password: 'secret'
      visit timelines_path
      fill_in "timeline_event[timeline_event][message]", with: "Please Filter Me"
      check "TimelineOne"
      check "TimelineTwo"
      click_button "Post"
      wait_until {  @user.timeline.reload.timeline_events.map(&:text).join(" ") =~ /testuser.*says/ }
      fill_in "timeline_event[timeline_event][message]", with: "Hello World!"
      click_button "Post"
      wait_until {  @user.timeline.reload.timeline_events.map(&:text).join(" ") =~ /testuser.*says/ }
      page.all( '.timeline-message', text: "Please Filter Me").count.should == 1
    end
  end

  describe "System Timelines" do

    before(:each) do
      Timeline.delete_all
      %w( doorkeeper admin ).each do |name|
        _t = Timeline.create(name: name, public: false, enabled: true )
        eval "@#{name}=_t"
        _t.facilities.create name: name.humanize, access: "rwx"
      end
    end

    it "Timelines#index should have check-boxes to select Timelines to post to" do
      # and any of the selected timelines will create it's own TimelineEvent
      @god = test_user( "God", "lights on", %w(Admin Doorkeeper) )
      @god.subscribe_timelines @doorkeeper, @admin
      sign_in_user name: "God", password: "lights on"
      visit timelines_path
      fill_in "timeline_event_timeline_event_message", with: "Wake up!"
      check "timelines_to_#{@admin._id}"
      check "timelines_to_#{@doorkeeper._id}"
      click_button "Post"
      @admin.reload.timeline_events.last.message.should == "Wake up!"
      @doorkeeper.reload.timeline_events.last.message.should == "Wake up!"
      @god.timeline.reload.timeline_events.last.message.should == "Wake up!"
    end

  end

  describe "Users personal Timeline" do
    before(:each) do
      Timeline.delete_all
    end

    describe  "Timelines#index" do
      it "creates a user-timeline on commit if not exists" do
        sign_in_user name: 'testuser', password: 'secret'
        visit timelines_path
        fill_in "timeline_name", with: "My cool words"
        click_button "Save"
        page.should have_content "My cool words"
      end
    end
  end

end