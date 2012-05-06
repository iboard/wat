require 'net/http'
require 'json'

class TwitterController < ApplicationController

  def user_tweets
    screen_name = params[:screen_name]
    max_entries = params[:max_entries] || Settings.max_twitter_messages || 3
    begin
      url = "http://api.twitter.com/1/statuses/user_timeline.json?include_rts=true&screen_name=%s&count=%d" % [screen_name,max_entries.to_i]
      res = Net::HTTP.get_response(URI(url))
      json = JSON::parse res.body
      messages = json.map do |r|
        date = I18n.l(Time.parse( r['created_at']), :format => :short)
        ("<div class='twitter-entry'>" +
           "<span class='screen-name'>" + 
             r['user']['screen_name'] + ", " + date + ": " +
           "</span>" +
           "<span class='twitter-message'>" + interpret(r['text']||"") + 
           "</span>" +
         "</div>")
      end
    rescue => e
      messages = e.inspect
    end
    respond_to do |format|
      format.json {
        render :json => messages
      }
    end
  end

  private
  def interpret text
    Markdown.render(text)
  end
 
end