module Doorkeeper

  def self.public_timeline
    @public_timeline ||= Timeline.find_or_create_by(name: 'doorkeeper')
  end

  def self.timeline
    Timeline.find_or_create_by(name: 'doorkeeper')
  end

  def self.events
    timeline.events.desc(:created_at)
  end

  def self.login(user_id,ip='0.0.0.0')
    event = timeline.create_event( { sender_id: user_id, message: 'logged_in', ip: ip}, DoorkeeperEvent)
    timeline.save
    event
  end

  def self.logout(user_id,ip='0.0.0.0')
    event = timeline.create_event( { sender_id: user_id, message: 'logged_out', ip: ip}, DoorkeeperEvent)
    timeline.save
    event
  end

end