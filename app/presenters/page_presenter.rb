class PagePresenter < BasePresenter

  presents :page

  attr_reader :vpage, :version

  def initialize(object, template)
    super
    setup_version(object)
  end
  
  def version_links
    if page.versions.any? && can_read?('Admin', 'Maintainer')
      (version_list_header + version_list).html_safe
    end
  end

  def title
    return page.title unless vpage
    _title = (vpage.title || translate_link).html_safe
    _title += "<small><em> (#{t(:version_number, version: version)})</em></small>".html_safe unless latest_version?
    _title.html_safe
  end

  def created_at
    I18n.l( vpage.created_at.localtime, format: :short )
  end

  def body
    interpret( (vpage.body||translate_link) )
  end

  def body_snippet _body_snippet
    if (_body_snippet||'').strip == (vpage.body||'').strip
      interpret( _body_snippet || translate_link )
    elsif _body_snippet
      strip_preview(strip_tags(_body_snippet))
    else
      translate_link
    end
  end

  def banner_preview
    if vpage.banner_exist?
      image_tag vpage.banner.banner.url(:preview), class: 'pull-right banner-preview' 
    end
  end

  def latest_version?
    version == page.version
  end

private
  def translate_link
    if vpage == page
      link_to( t(:please_translate_to, :lang => I18n.locale), edit_page_path(page) )
    else
      t(:this_version_has_no_translation_of, :lang => I18n.locale)
    end
  end

  def restore_link(v)
    return "PREVERSION" unless v
    if v != page.version && v == params[:version].to_i
      restore_button(v)
    elsif v == page.version 
      current_version_button
    else
      other_version_button(v)
    end
  end

  def link_to_version(v)
    return "PREVERSION" unless v
    _vpage = Version.new(page,v)
    (
      "<li class=\"row-fluid #{ v == version ? 'current-version' : ''}\">" +
          ( 
            versionlink_format % [
              (_vpage.updated_at||Time.now).strftime('%Y-%m-%d %H:%M'), 
              I18n.t(:age_in_words, distance: time_ago_in_words(_vpage.updated_at||Time.now()) ),
              _vpage.title||'NOT TRANSLATED YET',
              restore_link(v)
            ]
          ) +
      "</li>"
    ).html_safe
  end

  def versionlink_format
    "<span class='span2'>%s</span>"+
    "<span class='span2'><em>%s</em></span>"+
    "<span class='span5'>%s</span>" +
    "<span class='span2'>%s</span>"
  end

  def setup_version(object)
    if params[:version].present?
      @version = params[:version].to_i
      @vpage = Version.new(object,@version)
    end
    @version ||= object.version
    @vpage ||= object
  end

  def version_list_header
    "<h3 class='stamped'>" + t(:versions_of_this_document) + "</h3>"
  end

  def version_list
    _list = "<ul class='versions'>".html_safe
    page.available_versions.reverse.each do |v|
      _list += link_to( link_to_version(v).html_safe, page_path(page, version: v) )
    end
    _list += "</ul>".html_safe
    _list.html_safe
  end

  def strip_preview(_body_snippet)
    _txt = ""
    _txt = "<h3>" + vpage.title + "</h3>" if Settings.supress_page_title == true
    _txt += "<div class='snippet-preview'>" + strip_tags( _body_snippet ) + "</div>"
    _txt += "<div class='clear-both'></div>"
    _txt.html_safe
  end

  def restore_button(v)
    button_link_to( 'icon-repeat icon-white', 'btn btn-danger btn-mini span2', 
      t(:restore_version, version: v), restore_version_page_path(page,v), confirm: t(:are_you_sure)
    )
  end

  def current_version_button
    button_link_to( 'icon-asterisk', 'btn btn-success btn-mini span2', 
      t(:current_version), page
    )
  end

  def other_version_button(v)
    button_link_to( 'icon-cog', 'btn btn-mini span2', t(:show_version_number, version: v), page_path(page,version: v) )
  end

end