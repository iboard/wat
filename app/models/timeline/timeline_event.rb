# @class TimelineEvent
# Baseclass for all TimelineEvents.
class TimelineEvent
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :timeline
  field :message

  # if timelines_to is defined, copy event to other timelines
  after_create  :copy_events
  before_create :do_not_create_timeline_event_for_specs

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
    self.sender.try :postable_timelines if defined?(self.sender) && self.sender
  end
  def timelines_to=(_timelines)
    @timelines_to=_timelines
  end
  # @!endgroup

  # @!endgroup

  private

  def do_not_create_timeline_event_for_specs
    if $NO_TIMELINE_FOR_SPECS && $NO_TIMELINE_FOR_SPECS == true
      return false
    end
  end

  # Copy self (Event) to all other timelines, mentioned in @timelines_to
  def copy_events
    if @timelines_to && (@timelines_to -= [self.timeline.to_param]).any?
      _params = self.attributes.reject {|r| %w( _types _id id timeline_id).include?( r[0] ) }
      @timelines_to.each do |_tl|
        fire_event(_tl,_params) unless _tl == self.timeline._id
      end
    end
  end

  def fire_event(_timeline,_params)
    Timeline.find(_timeline).tap do |_t|
      _t.create_event(_params, _params['_type'].constantize) if _t.enabled
    end
  end

end