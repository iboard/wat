class TimelineEvent
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :timeline

  field :message

  default_scope -> {asc(:created_at)}

  def self.since(time)
    where(:created_at.gte => time)
  end

  def text
    message.strip
  end

  def current?
    self.created_at > Time.now-10.seconds
  end

  
end