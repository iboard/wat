# -*- encoding : utf-8 -*-"
#
# @author Andi Altendorfer <andreas@altendorfer.at>
#
require "rspec"

describe Timeline do

  before(:each) do
    Timeline.delete_all
    @timeline = Timeline.create( name: "First Timeline", public: true, enabled: true )
  end

  it "should provide list of Timelines" do
    visit "/api/v1/timelines"
    page.should have_content '"name":"First Timeline"'
  end

  it "provides events from timeline" do
    @timeline.create_event message: "Hello World"
    visit "/api/v1/timelines/#{@timeline._id}/events"
    page.should have_content '"message":"Hello World"'
  end

  describe "should accept POST to timeline events" do

    it "with event-param as standard RAILS hash" do
      post "/api/v1/timelines/#{@timeline._id}/create_event", event:  {message: "Hello World"}
      @timeline.reload.timeline_events.last.message.should == "Hello World"
      response.body.should have_content "\"message\":\"Hello World\""
    end

    it "with event-param as string to interpret as JSON" do
      post "/api/v1/timelines/#{@timeline._id}/create_event", event: '{"message":"Hello World"}'
      @timeline.reload.timeline_events.last.message.should == "Hello World"
      response.body.should have_content "\"message\":\"Hello World\""
    end

  end
end