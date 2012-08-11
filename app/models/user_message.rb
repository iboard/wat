class UserMessage < TimelineEvent

  field    :sender_id
  field    :receiver_ids, type: Array, default: []

  def receivers
    @receivers ||= User.any_in(_id: self.receiver_ids)
  end

  def sender
    @sender ||= User.find(self.sender_id)
  end

  def text
    return @text if @text
    params = { sender: self.sender.name, count: receivers.count, message: self.message }
    params.merge!( receiver: receivers.first.name ) if receivers.count == 1
    @text = I18n.t(:message_from_user_to_count_receivers, params )
  end
  
end