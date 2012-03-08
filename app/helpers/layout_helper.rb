module LayoutHelper

  def menu(&block)
    content_for :content_menu do
      yield
    end
  end

  def title(_title)
    content_for :title do
      _title
    end
    _title
  end

  def flash_alert type
    case type.to_s
    when 'notice' 
      'success'
    when 'alert'  
      'error'
    when 'message'
      'message'
    else 
      'info'
    end
  end

  def flash_title type
    case type.to_s
    when 'notice' 
      '<i class="icon-ok"></i> OK'
    when 'alert'  
      '<i class="icon-exclamation-sign"></i> ERROR'
    when 'info'
      '<i class="icon-info-sign"></i> Info'
    else 
      '<i class="icon-eye-open"></> Message'
    end
  end

  def top_menu(&block)
    content_for :top_menu do
      yield
    end
  end

  def button_link_to icon, classes, text, path, *args
    _options = args.any? ? args.first : {}
    _options.merge!( :class => classes, :style => 'text-align: left;' )
    if classes =~ /danger|primary|info|warning|success|warning/
      icon += " icon-white"
    end
    link_to(
        "<i class='#{icon}'></i>&nbsp;".html_safe +
        text,
        path,
        _options
      )
  end

end