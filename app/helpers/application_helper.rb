# -*- encoding : utf-8 -*-
require 'redcarpet'

module ApplicationHelper

  # To get some long text for specs and placeholders
  def lorem
    %{
      Lorem ipsum dolor sit amet, consectetur adipisicing elit, 
      sed do eiusmod tempor incididunt ut labore et dolore magna 
      aliqua. Ut enim ad minim veniam, quis nostrud exercitation 
      ullamco laboris nisi ut aliquip ex ea commodo consequat. 
      Duis aute irure dolor in reprehenderit in voluptate velit 
      esse cillum dolore eu fugiat nulla pariatur. Excepteur sint 
      occaecat cupidatat non proident, sunt in culpa qui officia 
      deserunt mollit anim id est laborum.
    }
  end

  def markdown(text)
    Markdown.render(text).html_safe
  end

  def present(object, klass = nil)
    klass ||= "#{object.class}Presenter".constantize
    presenter = klass.new(object, self)
    yield presenter if block_given?
    presenter
  end

  def ensure_default_search_box
    unless content_for?(:search_bar) || Settings.supress_global_search == true
      @search ||= Search.new search_text: '', search_controller: 'pages'
      render "shared/search"
    end
  end

  # Check if paginate is on last page
  # @param [WillPaginate-Array] collection
  # @return Boolean - true if on last page
  def is_on_last_page(collection)
    collection.total_pages && (collection.current_page < collection.total_pages)
  end

  # To use https://github.com/mislav/will_paginate in combination with Twitter-Bootstrap pagination
  # renderer is defined in config/initializers/bootstrap_link_renderer.rb
  # Possible usage see: README.md
  def page_navigation_links(pages, _class='pagination', _previous='&larr;', _next='&rarr;')
    if pages.total_pages > 1
      will_paginate(pages, class: _class, inner_window: 2, outer_window: 0, 
            renderer: ::BootstrapLinkRenderer, previous_label: _previous.html_safe, next_label: _next.html_safe).html_safe
    end
  end

end
