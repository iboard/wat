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
    event.text.should == 'testuser signed in, less than a minute ago'
    visit signout_path
  end

  it "logs user logouts to 'doorkeeper' timeline" do
    sign_in_user name: 'testuser', password: 'secret'
    visit root_path
    visit signout_path
    visit root_path
    event = Doorkeeper.latest_event
    event.sender.should == @user
    event.text.should == 'testuser signed out, less than a minute ago'
    visit signout_path
  end

  it "shows logins on the timelines-path" do
    sign_in_user name: 'testuser', password: 'secret'
    event = Doorkeeper.latest_event
    event.sender.should == @user
    visit timelines_path
    event.text.should == 'testuser signed in, less than a minute ago'
    page.should have_content 'testuser signed in, less than a minute ago'
    visit signout_path
  end

  it "shows notifications on any page" do
    sign_in_user name: 'testuser', password: 'secret'
    visit root_path
    page.should have_content 'testuser signed in, less than a minute ago'
  end

  it "offers a hide/show link", js: true do
    visit switch_language_path(:en)
    sign_in_user name: 'testuser', password: 'secret'
    page.should have_content 'testuser signed in, less than a minute ago'
    visit root_path
    click_link "Timeline"
    wait_until { page.all('#entries', :visible => false) }
    assert page.all('#entries', :visible => false) != nil, 'Timeline should be closed'
    click_link "Timeline"
    wait_until { page.all('#entries', :visible => true) }
    assert page.all('#entries', :visible => true) != nil, 'Timeline should be open'
  end

  it "Works but is untestable by now => allows a user to post messages", js: true do
    visit switch_language_path(:en)
    sign_in_user name: 'testuser', password: 'secret'
    fill_in "timeline_event[timeline_event][message]", with: "Hello World!"
    click_button "Post"
    wait_until {  Doorkeeper::timeline.reload.events.map(&:text).join(" ") =~ /testuser says/ }
    Doorkeeper.latest_event.text.should =~ /testuser says, 'Hello World!'/
  end

end