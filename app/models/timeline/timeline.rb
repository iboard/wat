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

  def self.find_by(options)
    where(options).first
  end

  # Virtual attribute. Data will not be stored in database
  # TimelinesController will use this field to set the session-var
  # for the timeline-duration to show
  def show_timeline_since
    (@show_timeline_since || 60)
  end

  def show_timeline_since=(minutes)
    @show_timeline_since = minutes
  end

  def since(time=nil)
    if time
      self.timeline_events.since(time)
    else
      self.timeline_events
    end
  end

  def create_event( event_options={}, _class=TimelineEvent )
    self.timeline_events.create( event_options, _class)
  end

  def events_from(user,_since=nil)
    since(_since).where(sender_id: user._id)
  end

  def events_for(user,_since=nil)
    since(_since).any_of( receiver_ids: user._id )
  end


  
end