class UserMessage < UserEvent

  field    :receiver_ids, type: Array, default: []

  def receivers
    @receivers ||= User.any_in(_id: self.receiver_ids)
  end

  def text
    return @text if @text
    if self.sender && self.receivers
      params = { sender: self.sender.name, count: receivers.count, message: self.message }
      params.merge!( receiver: receivers.first.name ) if receivers.count == 1
    else
      params = {sender: t(:unknown), count: 0, message: self.message }
    end
    @text = I18n.t(:message_from_user_to_count_receivers, params )
  rescue
    super
  end
  
end