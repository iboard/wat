require 'spec_helper'

describe Timeline do

  it "stores with a unique name" do
    $NO_TIMELINE_FOR_SPECS = false
    Timeline.create name: 'System Timeline'
    Timeline.find_by(name: 'System Timeline').name.should == 'System Timeline'
    Timeline.create(name: 'System Timeline').errors[:name].should include('is already taken')
    $NO_TIMELINE_FOR_SPECS = true
  end

  it "belongs to a user" do
    user = test_user "Mr. Nice", "secret"
    timeline = user.create_timeline name: 'My Timeline'
    timeline.user.should == user
  end

  describe  "can have facilities" do
    before(:each) do
      $NO_TIMELINE_FOR_SPECS = false
      @timeline = Timeline.create name: "With Facilities"
      @timeline.facilities.create name: 'Admin', access: 'rwx'
      @user = test_user "Admin", "secret", "Admin"
    end

    after(:each) do
      $NO_TIMELINE_FOR_SPECS = true
    end

    it "lists in user.postable_timelines if at least one facility matches" do
      user = test_user "Mr. Nice", "secret"
      @user.postable_timelines.should include(@timeline)
      @user.available_timelines.should include(@timeline)
      user.postable_timelines.should_not include(@timeline)
      user.available_timelines.should_not include(@timeline)
    end
  end

  describe TimelineEvent do

    before(:each) do
      @timeline = Timeline.create(name: 'User-actions')
    end

    it "can be embedded in a timeline" do
      event = @timeline.create_event( message: 'Timeline started' )
      @timeline.timeline_events.last.should == event
    end

    it "can list events since a given time" do
      event1 = @timeline.create_event( message: 'old entry', created_at: Time.now-1.year)
      event2 = @timeline.create_event( message: 'new entry')

      @timeline.since( Time.now-1.day ).map(&:message).should == ['new entry']
      @timeline.since( Time.now-2.years ).map(&:message).should == ['old entry','new entry']
    end

    it "doesn't allow similar event within threshold" do
      @user = test_user "Admin", "secret", "Admin"
      timeline = Timeline.find_or_create_by(name: "Threshold")
      event = timeline.create_event( sender_id: @user.id, message: "Test" )
      event.should_not be_nil
      event2 = timeline.create_event( sender_id: @user.id, message: "Test" )
      event2.should be_nil
    end

    describe UserMessage do
      before(:each) do
        $NO_TIMELINE_FOR_SPECS = false
        @sender   = User.create( name: 'Sender' )
        @receiver1= User.create( name: 'Receiver 1')
        @receiver2= User.create( name: 'Receiver 2')
  
        @event = @timeline.create_event( 
          { sender_id: @sender._id,
            receiver_ids: [@receiver1._id, @receiver2._id],
            message: "From Sender to Receivers"
          }, UserMessage
        )
        @timeline.timeline_events.count.should == 1
      end

      after(:each) do
        $NO_TIMELINE_FOR_SPECS = true
      end

      it "has a sender and a receiver" do
        @timeline.events_from(@sender).first.receivers.to_a.should == [@receiver1, @receiver2]
        @timeline.events_for(@receiver1).should == [@event]
        @timeline.events_for(@receiver2).should == [@event]
      end

      it "formats it's output in method text()" do
        @timeline.timeline_events.last.text.should =~ /Sender.*2 users.*'From Sender to Receivers'/
      end

    end
  end
  
end