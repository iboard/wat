# A timeline-event from one sender to an array of receivers
class UserMessage < UserEvent

  field    :receiver_ids, type: Array, default: []

  def receivers
    @receivers ||= User.any_in(_id: self.receiver_ids)
  end

  def text
    return @text if @text
    if self.sender && self.receivers
      params = { sender: self.sender.name, count: receivers.count, message: self.message, time: I18n.l(Time.now,format: "%H:%M") }
      params.merge!( receiver: receivers.first.name ) if receivers.count == 1
    else
      params = {sender: t(:unknown), count: 0, message: self.message, time: I18n.l(Time.now,format: "%H:%M") }
    end
    @text = I18n.t(:message_from_user_to_count_receivers, params )
  rescue
    super
  end
  
end