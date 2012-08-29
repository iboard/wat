require "rspec"

describe TimelineSubscription do

  before(:each) do
    @user = test_user 'Mr. Test', 'secret'
    @public_timeline= Timeline.find_or_create_by(name: 'doorkeeper')
    @contentkeeper = Timeline.create(name: 'content-timeline')
  end

  it "can be added to a user" do
    @user.subscribe_timelines(@public_timeline,@contentkeeper)
    @user.timeline_subscriptions.count.should == 2
    @user.timeline_subscriptions.map(&:timeline).should == [@public_timeline,@contentkeeper]
  end

  it "can be removed from a user" do
    @user.subscribe_timelines(@public_timeline,@contentkeeper)
    @user.timeline_subscriptions.map(&:timeline).should == [@public_timeline,@contentkeeper]
    @user.unsubscribe_timelines(@public_timeline)
    @user.timeline_subscriptions.count.should == 1
    @user.timeline_subscriptions.map(&:timeline).should == [@contentkeeper]
  end

  it "can be asked if user subscribed" do
    @user.subscribe_timelines(@public_timeline)
    @user.subscribed_to?(@public_timeline).should be_true
    @user.subscribed_to?(@contentkeeper).should be_false
  end

end