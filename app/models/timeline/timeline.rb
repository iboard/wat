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
    _count = 0
    _distance = distance_for( "#{_class}" )
    if _distance > 0
      _search = { :_type => "#{_class}" }
      _search.update( event_options ) if event_options != {}
      _count = since(Time.now - _distance.seconds).where( _search ).count
    end
    self.timeline_events.create( event_options, _class) unless _count > 0
  end

  def events_from(user,_since=nil)
    since(_since).where(sender_id: user._id)
  end

  def events_for(user,_since=nil)
    since(_since).any_of( receiver_ids: user._id )
  end

  # @!endgroup

  private
  def distance_for(_class)
    _d = eval( "Settings.#{_class.to_s.underscore}_distance_in_seconds" ) || "0"
    eval _d.to_s
  end

end