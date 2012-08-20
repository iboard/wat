# -*- encoding : utf-8 -*-"
#
# Created by Andi Altendorfer <andreas@altendorfer.at>, 20.08.12, 13:33
#
#
module TimelinesHelper
  def post_message_css_options
    if is_action?(:index)
      {:class => "full-width"}
    else
      {}
    end
  end
end