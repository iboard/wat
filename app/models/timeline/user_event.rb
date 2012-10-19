class UserEvent < TimelineEvent

  include ActionView::Helpers::DateHelper

  field    :sender_id

  def sender
    @sender ||= User.where(_id: self.sender_id).first if self.sender_id
  end

  def text
    I18n.t( :user_action_event,
            user: sender_markdown_link,
            sender: sender_markdown_link,
            time: time_ago_in_words( self.created_at ),
            action: I18n.t(self.message.to_sym)
    )
  rescue => e
    super + ">>> #{e.inspect}".html_safe
  end

  private
  def sender_markdown_link
    "[#{sender.name}](/users/#{sender._id}/profile)"
  end

end