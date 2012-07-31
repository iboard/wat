class SectionPresenter < BasePresenter
  presents :section

  def title
    section.title || 'unnamed'
  end

  def description
    markdown( section.body )
  end

  def page_links
    rc = "<ul class='nav nav-pills'>"
      section.pages.only(:title).each do |page|
        rc += "<li>" + link_to(page.title,page) + "</li>"
      end
    rc += "</ul>"
    rc.html_safe
  end
end
