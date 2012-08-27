require 'spec_helper'

describe TimelinesController do

  before(:each) do
    User.delete_all
    Identity.delete_all
    @user = test_user 'testuser', 'secret'
  end

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

end