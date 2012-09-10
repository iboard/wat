class Timeline

  DEFAULT_RELOAD_TIME = 10.seconds

  include Mongoid::Document
  include Mongoid::Timestamps

  field                   :name
  validates_presence_of   :name
  validates_uniqueness_of :name

  field                   :enabled, type: Boolean, default: true
  field                   :public,  type: Boolean, default: true

  embeds_many  :timeline_events
  accepts_nested_attributes_for :timeline_events

  belongs_to :user

  has_many :timeline_subscriptions
  embeds_many :facilities, as: :facilitizer

  scope :enabled, -> { where(enabled: true) }
  scope :public,  -> { where(public: true)  }

 # @!group Virtual Attributes

  # Virtual attribute. Data will not be stored in database
  # TimelinesController will use this field to set the session-var
  # for the timeline-duration to show
  def show_timeline_since
    (@show_timeline_since || 60)
  end

  def show_timeline_since=(minutes)
    @show_timeline_since = minutes
  end

  # @!endgroup

  # @!group Finders

  def self.find_by(options)
    where(options).first
  end

  def since(time=nil)
    if time
      self.timeline_events.since(time)
    else
      self.timeline_events
    end
  end

  def create_event( event_options={}, _class=TimelineEvent )
    self.timeline_events.create( event_options, _class) if allow_event?(event_options, _class)
  end

  def events_from(user,_since=nil)
    since(_since).where(sender_id: user._id)
  end

  def events_for(user,_since=nil)
    since(_since).any_of( receiver_ids: user._id )
  end

  # @!endgroup

  private

  # Check if it's allowed to create the event
  # By now there is one check only (Thresholding). Further checks can be added here
  # @return Boolean - true if it's ok to create the event.
  def allow_event?(event_options, _class)
    ! threshold_reached?(_class, event_options, distance_for( _class ))
  end

  def threshold_reached?(_class, event_options, threshold)
    return false if threshold == 0
    _search = {:_type => _class.to_s}
    _search.update(event_options) if event_options != {}
    since(Time.now - threshold.seconds).where(_search).count > 0
  end

  def distance_for(_class)
    begin
      eval( "Settings.timeline.event_classes.#{_class.to_s.underscore}.threshold" )
    rescue
      0
    end
  end
end