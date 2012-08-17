require "rspec"

describe TimelineSubscription do

  before(:each) do
    @user = test_user 'Mr. Test', 'secret'
    @public_timeline= Doorkeeper::timeline
    @contentkeeper = Timeline.create(name: 'content-timeline')
  end

  it "can be added to a user" do
    @user.subscribe_timelines(@public_timeline,@contentkeeper)
    @user.timeline_subscriptions.count.should == 2
    @user.timeline_subscriptions.map(&:timeline).should == [@public_timeline,@contentkeeper]
  end

end