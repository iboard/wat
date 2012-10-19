class UserChangedEvent < UserEvent

  include ActionView::Helpers::DateHelper

  field  :what
  field  :user_name

  def text
    begin
      I18n.t(:user_changed, user: user_name, what: I18n.t(:"#{what}"),
         time: time_ago_in_words(self.created_at))
    rescue => e
      e.inspect
    end
  end
end