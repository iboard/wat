class BasePresenter
  
  def initialize(object, template)
    @object = object
    @template = template
  end
  
  def self.presents(name)
    define_method(name) do
      @object
    end
  end
  
  def h
    @template
  end

  def method_missing(*args, &block)
    @template.send(*args, &block)
  end

  def interpret text
    markdown(parse(text)).html_safe
  end

  private
  def parse text
    text.gsub /(\[TWITTER_USER\:)(\S+)(,(\d+))?\]/ do |args|
      params = args.gsub(/[\[|\]]/,'').split(/\:|,/)
      "<div class='twitter-user' data-screen-name='#{params[1]}' data-num-tweets='#{params[2]||Settings.max_twitter_messages||3}'>#{params[1]}...</div>"
    end
  end
  
end