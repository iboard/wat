class UserEvent < TimelineEvent

  field    :sender_id

  def sender
    begin
      @sender ||= User.find(self.sender_id)
    rescue
      nil
    end
  end


end