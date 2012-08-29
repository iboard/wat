class TimelineEvent
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :timeline
  field :message

  after_create  :fire_timeline_events

  def self.since(time)
    where(:created_at.gte => time)
  end

  def text
    (message||"").strip
  end

  # @return [Boolean] - true if younger than Timeline::DEFAULT_RELOAD_TIME
  def current?
    (self.created_at||self.updated_at||Time.now) > Time.now-Timeline::DEFAULT_RELOAD_TIME.seconds
  end

  # @!group Virtual Attributes

  # @!group timelines_to - Deliver copy to other timelines
  def timelines_to
    self.sender.try :timeline_subscriptions if defined?(self.sender) && self.sender
  end
  def timelines_to=(_timelines)
    @timelines_to=_timelines
  end
  # @!endgroup

  private

  # Create self (Event) in all other timelines, mentioned in @timelines_to
  def fire_timeline_events
    if @timelines_to && (@timelines_to -= [self.timeline.to_param]).any?
      _params = self.attributes.reject {|r| %w( _types _id id timeline_id).include?( r[0] ) }
      @timelines_to.each do |_tl|
        fire_event(_tl,_params) unless _tl == self.timeline._id
      end
    end
  end

  #
  def fire_event(_timeline,_params)
    Timeline.find(_timeline).tap do |_t|
      _t.create_event(_params, _params['_type'].constantize) if _t.enabled
    end
  end

end