class TimelineEvent
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :timeline

  field :message

  def self.since(time)
    where(:created_at.gte => time)
  end

  def text
    (message||"").strip
  end

  def current?
    (self.created_at||self.updated_at||Time.now) > Time.now-10.seconds
  end

end