# DoorkeeperEvents are fired by User-actions as 'login, logout, ...'
class DoorkeeperEvent < UserEvent

  include ActionView::Helpers::DateHelper

  field  :ip

  def text
    I18n.t( :user_action_event, 
       user: self.sender.name, 
       time: distance_of_time_in_words( Time.now, self.created_at ),
       action: I18n.t(self.message.to_sym)
      )
  rescue
    super
  end

end