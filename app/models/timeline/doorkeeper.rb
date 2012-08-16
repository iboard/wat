module Doorkeeper

  DOORKEEPER_TIMELINE = 'doorkeeper'

  def self.login(*args)
    @doorkeeper.login(*args)
  end

  def self.logout(*args)
    @doorkeeper.logout(*args)
  end

  def self.public_timeline
    @doorkeeper.public_timeline
  end

  def self.timeline
    @doorkeeper.timeline
  end

  def self.events
    @doorkeeper.events
  end

  def self.latest_event
    @doorkeeper.latest_event
  end


  class TimelineLogger

    attr_reader :timeline, :public_timeline

    def initialize
      @public_timeline ||= Timeline.find_or_create_by(name: DOORKEEPER_TIMELINE)
      @timeline ||= Timeline.find_or_create_by(name: DOORKEEPER_TIMELINE)
    end

    def events(limit=60)
      timeline.timeline_events.desc(:created_at).limit(limit)
    end

    def latest_event
      timeline.timeline_events.desc(:created_at).first
    end

    def clear_timeline
      timeline.events.delete_all
      timeline.save
    end

    def login(user_id,ip='0.0.0.0')
      event = timeline.create_event( { sender_id: user_id, message: 'logged_in', ip: ip}, DoorkeeperEvent)
      timeline.save ? event : nil
    end

    def logout(user_id,ip='0.0.0.0')
      event = timeline.create_event( { sender_id: user_id, message: 'logged_out', ip: ip}, DoorkeeperEvent)
      timeline.save ? event : nil
    end

  end


  @doorkeeper ||= TimelineLogger.new

end