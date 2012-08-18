require "rspec"

describe User do

  before(:each) do
    @user = test_user 'Mr. Test', 'secret'
    @doorkeeper= Timeline.find_or_create_by( name: Doorkeeper::DOORKEEPER_TIMELINE)
    @contentkeeper = Timeline.create(name: 'content-timeline')
  end

  it "can subscribe and read events from all subscriptions/timelines" do
    @user.subscribe_timelines(@doorkeeper, @contentkeeper)
    _t = Time.now
    @doorkeeper.create_event({sender_id: @user._id, message: 'logged_in', created_at: _t}, DoorkeeperEvent)
    @contentkeeper.create_event(message: 'Event One', created_at: _t + 1.second)
    @doorkeeper.create_event({sender_id: @user._id, message: 'logged_out', created_at: _t + 2.second}, DoorkeeperEvent)
    @contentkeeper.create_event(message: 'Event Two', created_at: _t + 3.second)
    @user.reload
    @user.events.map(&:message).should == ['logged_in', 'Event One', 'logged_out', 'Event Two' ]
  end

  it "has it's own timeline" do
    @user.timeline.name.should == "user-posts-%s" % [@user._id]
  end

end