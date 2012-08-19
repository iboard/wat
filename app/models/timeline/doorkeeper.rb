# Doorkeeper is aimed to handle a 'global' Timeline
# @todo Needs review regarding thread-safety.
# @todo TimelineEvents should be listed bottom-top but sorting embedded objects doesn't work with curren mongoid-version
module Doorkeeper

  class DoorkeeperError < RuntimeError

    def initialize( _timeline, _message='' )
      @timeline = _timeline
      @error_message = _message
    end

    def message
      "TimelineError #{@timeline.inspect} #{@error_message}"
    end

  end

  unless defined?(DOORKEEPER_TIMELINE)
    DOORKEEPER_TIMELINE = 'doorkeeper'


    def self.create_event(*args)
      _tl = Timeline.find_or_create_by(name: DOORKEEPER_TIMELINE)
      _tl.create_event *args
    end

    class << self

      def configure
        yield self
      end

      def doorkeeper=(_new)
        @doorkeeper = _new
      end

      def doorkeeper
        @doorkeeper ||= TimelineLogger.new
      end

      def timeline
        doorkeeper.timeline
      end

      def method_missing(*args, &block)
        doorkeeper.send(*args, &block) unless args.first == "*"
      end
    end


    class TimelineLogger

      attr_reader :timeline

      def initialize
        @timeline = Timeline.find_or_create_by(name: DOORKEEPER_TIMELINE)
      end

      def events(_limit=60)
        timeline.reload.timeline_events.limit(_limit)
      end

      def latest_event
        timeline.reload.timeline_events.last
      end

      def login(user_id, ip='0.0.0.0')
        timeline.create_event({sender_id: user_id, message: 'logged_in', ip: ip}, DoorkeeperEvent)
      end

      def logout(user_id, ip='0.0.0.0')
        timeline.create_event({sender_id: user_id, message: 'logged_out', ip: ip}, DoorkeeperEvent)
      end

    end
  end
end