# -*- encoding : utf-8 -*-"
#
# @author Andi Altendorfer <andreas@altendorfer.at>
#

class TimelineEventPresenter < BasePresenter

  presents :timeline_event

  def css_class_definition
    "bubble timeline-event #{css_class_name} #{latest_event_class}"
  end

  def timeline_name
    timeline_event.timeline.name
  end

  def avatar
    content_tag :div, class: 'timeline-avatar' do
      if timeline_event.respond_to?(:sender) && timeline_event.sender
        image_tag timeline_event.sender.picture(:tiny), style: "width: 32px; height: 32px;"
      else
        "<i class='icon-comment'></i>".html_safe
      end
    end
  end

  def body
    markdown((sanitize(timeline_event.text)))
  end

  private
  def css_class_name
    timeline_event.class.to_s.underscore.gsub(/_/,'-')
  end

  def latest_event_class
    timeline_event.current? ? 'latest-timeline-event' : ''
  end

end