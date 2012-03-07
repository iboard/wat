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
    Markdown.render(text).gsub(/\n/,"<br/>").html_safe
  end
  
end
