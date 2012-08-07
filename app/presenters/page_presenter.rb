class PagePresenter < BasePresenter

  presents :page

  def title
    page.title || translate_link
  end

  def created_at
    I18n.l( page.created_at.localtime, format: :short )
  end

  def body
    interpret (page.body||translate_link)
  end

  def body_snippet body_snippet
    if body_snippet == page.body
      interpret( body_snippet || translate_link )
    else
      if body_snippet
        strip_tags body_snippet
      else
        translate_link
      end
    end
  end

  def banner_preview
    if page.banner_exist?
      image_tag page.banner.banner.url(:preview), class: 'pull-right banner-preview' 
    end
  end

private
  def translate_link
    link_to( t(:please_translate_to, :lang => I18n.locale), edit_page_path(page) )
  end

end