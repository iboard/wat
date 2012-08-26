require 'spec_helper'

describe Timeline do

  it "stores with a unique name" do
    Timeline.create name: 'System Timeline'
    Timeline.find_by(name: 'System Timeline').name.should == 'System Timeline'
    Timeline.create(name: 'System Timeline').errors[:name].should include('is already taken')
  end

  it "belongs to a user" do
    user = test_user "Mr. Nice", "secret"
    timeline = user.create_timeline name: 'My Timeline'
    timeline.user.should == user
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

    describe UserMessage do
      before(:each) do
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
  
      it "has a sender and a receiver" do
        @timeline.events_from(@sender).first.receivers.to_a.should == [@receiver1, @receiver2]
        @timeline.events_for(@receiver1).should == [@event]
        @timeline.events_for(@receiver2).should == [@event]
      end

      it "formats it's output in method text()" do
        @timeline.timeline_events.last.text.should =~ /Sender to 2 users, 'From Sender to Receivers'/
      end

    end
  end
  
end