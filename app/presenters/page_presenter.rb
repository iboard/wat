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
    interpret( body_snippet || translate_link )
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