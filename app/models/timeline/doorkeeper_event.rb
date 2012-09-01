# DoorkeeperEvents are fired by User-actions as 'login, logout, ...'
class DoorkeeperEvent < UserEvent

  include ActionView::Helpers::DateHelper

  field  :ip

end