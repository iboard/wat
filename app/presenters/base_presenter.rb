class BasePresenter
  
  include TwitterApi

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
      twitter_user(params[1],params[2]||Settings.max_twitter_messages||3)
    end
  end
  
end