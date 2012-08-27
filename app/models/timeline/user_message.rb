# A timeline-event from one sender to an array of receivers
class UserMessage < UserEvent
  include ActionView::Helpers::DateHelper

  field    :receiver_ids, type: Array, default: []

  def receivers
    @receivers ||= User.any_in(_id: self.receiver_ids)
  end

  def text
    return @text if @text
    if self.sender && self.receivers
      params = { sender: "[#{sender.name}](/users/#{sender._id}/profile)", count: receivers.count, message: self.message, time: distance_of_time_in_words( Time.now, self.created_at ) }
      params.merge!( receiver: "[#{receivers.first.name}](/users/#{receivers.first._id}/profile)") if receivers.count == 1
    else
      params = {sender: t(:unknown), count: 0, message: self.message, time: distance_of_time_in_words( Time.now, self.created_at ) }
    end
    @text = I18n.t(:message_from_user_to_count_receivers, params )
  rescue
    super
  end
  
end