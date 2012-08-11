class Timeline
  include Mongoid::Document
  include Mongoid::Timestamps

  field                  :name
  validates_presence_of  :name
  validates_uniqueness_of :name

  embeds_many  :timeline_events

  def self.find_by(options)
    where(options).first
  end

  def events
    self.timeline_events
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