# A timeline-event from one sender to an array of receivers
class UserMessage < UserEvent
  include ActionView::Helpers::DateHelper

  field    :receiver_ids, type: Array, default: []

  def receivers
    @receivers ||= User.any_in(_id: self.receiver_ids)
  end

  def text
    @text ||= I18n.t(:message_from_user_to_count_receivers, prepare_params )
  rescue
    super
  end

  private

  def prepare_params
    if self.sender && self.receivers
      params = text_params
      params.merge!(receiver: receiver_markdown_link) if receivers.count == 1
    else
      params = {sender: t(:unknown), count: 0, message: self.message, time: distance_of_time_in_words(Time.now, self.created_at)}
    end
    params
  end

  def text_params
    {
        sender: sender_markdown_link,
        count: receivers.count,
        message: self.message,
        time: distance_of_time_in_words(Time.now, self.created_at)
    }
  end

  def receiver_markdown_link
    "[#{receivers.first.name}](/users/#{receivers.first._id}/profile)"
  end

end