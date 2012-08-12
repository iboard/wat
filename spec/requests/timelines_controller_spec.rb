require 'spec_helper'

describe TimelinesController do

  before(:each) do
    Timeline.delete_all
    User.delete_all
    Identity.delete_all
    @user = test_user 'testuser', 'secret'
  end

  it "logs user logins and logouts to 'doorkeeper' timeline" do
    sign_in_user name: 'testuser', password: 'secret'
    doorkeeper = Timeline.first
    event = doorkeeper.events.last
    event.sender.should == @user
    event.text.should == 'testuser signed in, less than a minute ago'

    visit signout_path
    doorkeeper.reload
    event = doorkeeper.events.last
    event.sender.should == @user
    event.text.should == 'testuser signed out, less than a minute ago'
  end

  it "shows logins on the timelines-path" do
    sign_in_user name: 'testuser', password: 'secret'
    doorkeeper = Timeline.first
    event = doorkeeper.events.last
    event.sender.should == @user
    visit timelines_path
    event.text.should == 'testuser signed in, less than a minute ago'
    page.should have_content 'testuser signed in, less than a minute ago'
  end

  it "shows notifications on any page" do
    sign_in_user name: 'testuser', password: 'secret'
    visit root_path
    page.should have_content 'testuser signed in, less than a minute ago'
  end

  it "offers a hide/show link", js: true do
    visit switch_language_path(:en)
    sign_in_user name: 'testuser', password: 'secret'
    visit root_path
    page.should have_content 'testuser signed in, less than a minute ago'
    click_link "Timeline"
    wait_until { page.all('#entries', :visible => false)}
    assert page.all('#entries', :visible => false) != nil, 'Timeline should be closed'
    click_link "Timeline"
    wait_until { page.all('#entries', :visible => true)}
    assert page.all('#entries', :visible => true) != nil, 'Timeline should be open'
  end
  
end