class PagePresenter < BasePresenter

  presents :page

  attr_reader :vpage, :version

  def initialize(object, template)
    super
    if params[:version].present?
      @version = params[:version].to_i
      @vpage = Version.new(object,@version,I18n.locale.to_sym)
    end
    @version ||= object.version
    @vpage ||= object
  end
  
  def version_links
    if page.versions.any? && can_read?('Admin', 'Maintainer')
      _versions = "<h3 class='stamped'>" + t(:versions_of_this_document) + "</h3>"
      _versions += "<ul class='versions'>".html_safe
      page.available_versions.reverse.each do |v|
        _versions += link_to( link_to_version(v).html_safe, page_path(page, version: v) )
      end
      _versions += "</ul>".html_safe
      _versions.html_safe
    end
  end

  def title
    return page.title unless vpage
    if version == page.version
      (vpage.title || translate_link).html_safe
    else
      ((vpage.title || translate_link) + "<small><em> (Version: #{version})</em></small>").html_safe 
    end
  end

  def created_at
    I18n.l( vpage.created_at.localtime, format: :short )
  end

  def body
    interpret (vpage.body||translate_link)
  end

  def body_snippet _body_snippet
    if _body_snippet == vpage.body
      interpret( _body_snippet || translate_link )
    elsif _body_snippet
      _txt = ""
      _txt = vpage.title if Settings.supress_page_title == true
      _txt += strip_tags _body_snippet
      _txt += "<div class='clear-both'></div>"
      _txt.html_safe
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
    if v != page.version && v != params[:version].to_i
      button_link_to( 'icon-repeat icon-white', 'btn btn-danger btn-mini span2', 
        t(:restore_version, version: v), restore_version_page_path(page,v), confirm: t(:are_you_sure)
      )
    elsif v == page.version 
      button_link_to( 'icon-asterisk', 'btn btn-success btn-mini span2', 
        t(:current_version), page
      )
    else
      button_link_to( 'icon-cog', 'btn btn-mini span2', t(:version_number, version: v), page_path(page,version: v) )
    end
  end

  def link_to_version(v)
    return "PREVERSION" unless v
    _vpage = Version.new(page,v,I18n.locale.to_sym)
    (
      "<li class=\"row-fluid #{ v == version ? 'label label-info current-version' : 'label label-message'}\">" +
          ( 
            versionlink_format % [
              _vpage.updated_at.strftime('%Y-%m-%d %H:%M'), 
              I18n.t(:age_in_words, distance: time_ago_in_words(_vpage.updated_at) ),
              _vpage.title,
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

end