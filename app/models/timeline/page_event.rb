# -*- encoding : utf-8 -*-"
#
# Created by Andi Altendorfer <andreas@altendorfer.at>, 19.08.12, 16:15
#
#

class PageEvent < DoorkeeperEvent

  include ActionView::Helpers::DateHelper

  field :page_id

  def page
    @page ||= Page.find(self.page_id) if self.page_id
  end

  def text
    @text ||= I18n.t(:page_event,
                     user: "[#{sender.name}](/users/#{sender._id}/profile)",
                     action: I18n.t(self.message.to_sym),
                     time: distance_of_time_in_words(Time.now, self.created_at),
                     page: "[#{page.title}](/pages/#{page._id})"
    )
  rescue => e
    self.message += " ??? " + e.inspect
    super
  end

end

