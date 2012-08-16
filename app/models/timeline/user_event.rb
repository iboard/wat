class UserEvent < TimelineEvent

  field    :sender_id

  def sender
    @sender ||= User.where(_id: self.sender_id).first if self.sender_id
  end
end