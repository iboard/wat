class TimelineSubscription
  include Mongoid::Document

  belongs_to :user
  belongs_to :timeline

end