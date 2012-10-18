class ProfileChangedEvent < UserEvent

  include ActionView::Helpers::DateHelper

  field  :what

  def text
    begin
      I18n.t(:profile_changed, user: sender.name, what: I18n.t(:"#{what}"),
         time: time_ago_in_words(self.created_at))
    rescue => e
      e.inspect
    end
  end
end