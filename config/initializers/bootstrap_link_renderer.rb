# Based on https://gist.github.com/1182136
# Changes by Karl Hochfilzer
class BootstrapLinkRenderer < ::WillPaginate::ViewHelpers::LinkRenderer
  protected

  def html_container(html)
    tag :div, tag(:ul, html), container_attributes
  end

  def page_number(page)
    tag :li, link(page, page == current_page ? 'javascript:void(0)' : page, rel: rel_value(page), class: 'btn btn-small'), 
      class: ('active disabled' if page == current_page)
  end

  def gap
    tag :li, link( " ... ", 'javascript:void(0)', class: 'btn btn-small'), class: ('disabled')
  end

  def previous_or_next_page(page, text, classname)
    if text == ""
      case classname
        when "previous_page"
          text = "<span class='btn'><i class='icon-arrow-left'></i></span>".html_safe
        when "next_page"
          text = "<span class='btn'><i class='icon-arrow-right'></i></span>".html_safe
      end
    end
    tag :li, link(text, page || 'javascript:void(0)', class: 'btn btn-small'), 
      class: [classname, ( "disabled" unless page)].join(' ')
  end

end
