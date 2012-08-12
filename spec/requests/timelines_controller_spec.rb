require 'spec_helper'

  # Send a key to an input-field
  # @param String key - eg 'return'
  # @param Hash options - to: '#css-id-of-the-input'
  def send_key(key, options={})
    _keycode = case key
    when :return
      '13'
    else
      key
    end
    _script = "$('#{options[:to]}').focus().append('#{_keycode}');"
    page.driver.browser.execute_script(_script)
  end

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
    event = doorkeeper.events.first
    event.sender.should == @user
    event.text.should == 'testuser signed in, less than a minute ago'

    visit signout_path
    doorkeeper = Timeline.first
    doorkeeper.reload
    event = doorkeeper.events.first
    event.sender.should == @user
    event.text.should == 'testuser signed out, less than a minute ago'
  end

  it "shows logins on the timelines-path" do
    sign_in_user name: 'testuser', password: 'secret'
    doorkeeper = Timeline.first
    event = doorkeeper.events.first
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

  pending " => Works but is untestable by now => allows a user to post messages", js: true do
    visit switch_language_path(:en)
    sign_in_user name: 'testuser', password: 'secret'
    visit root_path
    wait_until { page.has_css?("#timeline_event_timeline_event_message") }
    page.driver.browser.execute_script("$('#timeline_event_timeline_event_message').val('Hello World!');")
    page.find('#submit').click()
    Doorkeeper::public_timeline.events.first.text.should == "testuser says, 'Hello World!' [less than a minute ago]"
  end
  
end