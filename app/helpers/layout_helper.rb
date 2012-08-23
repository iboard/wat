# -*- encoding : utf-8 -*-
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
      '<i class="icon-eye-open"></i> Message'
    end
  end

  def top_menu(&block)
    content_for :top_menu do
      yield
    end
  end

  def button_to icon, classes, text, path, *args
    _options = args.any? ? args.first : {}
    _options.merge!( :style => 'text-align: left;' )
    if classes =~ /danger|primary|info|warning|success|warning/
      icon += " icon-white"
    end
    content_tag :button, class: classes do
      link_to(
          "<i class='#{icon}'></i>&nbsp;".html_safe +
          text,
          path,
          _options
        )
    end
  
  end


  def button_link_to icon, classes, text, path, *args
    _options = args.any? ? args.first : {}
    _options.merge!( :style => 'text-align: left;',:class => classes )
    if classes =~ /danger|primary|info|warning|success|warning/
      icon += " icon-white"
    end
    content_tag :span do
      link_to(
          "<i class='#{icon}'></i>&nbsp;".html_safe +
          text,
          path,
          _options
        )
    end
  end

  def close_icon
    '<a class="close" data-dismiss="alert">&times;</a>'.html_safe
  end


  def errors_for(item)
    if item.errors.any?
      content_tag :div, :class => "alert" do
        close_icon +
        "<h3>".html_safe +
        t(:errors_prevent_item_from_saving, :item => item.class.to_s.humanize, :count => item.errors.count) +
        "</h3>".html_safe +
        item.errors.map do |field, message|
          content_tag :div, :class => "alert alert-error" do
            "<i class='icon-exclamation-sign'></i>&nbsp;".html_safe +
            "<b>#{field.to_s.humanize}</b><br/>".html_safe +
            message
          end
        end.join("\n").html_safe
      end
    end
  end

  def error_class(item, field)
    item.errors[field].present? ? {class: "error"} : {class: ''}
  end

  def error_message_for(item,field)
    if item.errors.any? && item.errors[field]
      item.errors[field].join(", ")
    end
  end

  def icon_label( icon, classes, text, *args)
    options = {
      :class => classes
    }
    args.each{ |a| options.merge!(a) }
    content_tag :div, options do
      content_tag :span do
        content_tag( :i, :class => icon){"&nbsp;".html_safe} +
        "&nbsp;".html_safe+
        content_tag( :span, text)
      end
    end.html_safe
  end

  def label_link_to( icon, classes, text, *args)
    link_to icon_label(icon+" icon-white",classes,text), *args
  end

  def icon_link_to( icon, classes, text, *args)
    link_to icon_label(icon,classes,text), *args
  end

  def icon_prefix(icon,text)
    content_tag :span do
      content_tag( :i, :class => icon) {} + text
    end
  end

  def icon(icon,classes="")
    content_tag :i, :class => icon + " #{classes}" do
    end
  end

  def carret
    '<b class="caret"></b>'.html_safe
  end

  def error_label(item,field,span='')
    if item.errors[field].present?
      icon_label 'icon-warning-sign icon-white', "label label-important #{span}", error_message_for(item,field)
    end
  end

  def humanized_filesize(bytes)
    x = if bytes < 1.kilobyte
      t(:number_of_bytes, count: bytes)
    elsif bytes < 1.megabyte
      t(:number_of_kilobytes, count: (bytes/1.kilobyte).to_i)
    elsif bytes < 1.gigabyte
      t(:number_of_megabytes, count: (bytes/1.megabyte).to_i)
    elsif bytes < 1.terabyte
      t(:number_of_gigabytes, count: (bytes/1.gigabyte).to_i)
    else
      t(:number_of_terabytes, count: (bytes/1.terabyte).to_i)
    end
    x
  end

  def datepicker( field, value )
    _date = value ? value.strftime('%Y-%m-%d') : (Time.now+1.year).strftime('%Y-%m-%d')
    ( "&nbsp;"*3 +
      "<div class='input-append date' id='dp3' data-date='#{_date}' data-date-format='yyyy-mm-dd'>" +
        "<input class='span2' size='16' type='text' value='#{_date}' name='#{field}'>" +
        "<span class='add-on datepicker'><i class='icon-th'></i></span>" +
      "</div>"
    ).html_safe
  end

end