class UserEvent < TimelineEvent

  field    :sender_id

  def sender
    @sender ||= User.where(_id: self.sender_id).first if self.sender_id
  end

  def text
    I18n.t( :user_action_event,
            user: "[#{sender.name}](/users/#{sender._id}/profile)",
            sender: "[#{sender.name}](/users/#{sender._id}/profile)",
            time: distance_of_time_in_words( Time.now, self.created_at ),
            action: I18n.t(self.message.to_sym)
    )
  rescue => e
    super + ">>> #{e.inspect}".html_safe
  end
end