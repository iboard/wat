module TwitterApi

  require 'net/http'
  require 'json'

  
  def self.included(base)
    base.send :include, ClassMethods
  end

  module ClassMethods
    def twitter_user(search,max)
      begin
        url = "http://api.twitter.com/1/statuses/user_timeline.json?include_rts=true&screen_name=%s&count=%d" % [search,max.to_i]
        res = Net::HTTP.get_response(URI(url))
        json = JSON::parse res.body
        messages = json.map do |r| 
          r['user']['screen_name'] + ": " + r['text']||""
        end
        messages.join("\n<br/>\n".html_safe)
      rescue => e
        e.inspect
      end
    end
  end

end