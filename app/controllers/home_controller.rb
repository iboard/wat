# -*- encoding : utf-8 -*-
class HomeController < ApplicationController
  include Redirect::RootPath
  
  # def index
  def home_index
    Rails.logger.info("HomeController index: params? #{params.inspect} 
      session? #{session.inspect} 
      current_user? #{current_user.inspect}")
    if can_read?('Admin', 'Maintainer')
      @hero = Page.where(_id: 'hero').first
      @features = Page.featured
    else
      @hero = Page.online.where(_id: 'hero').first
      @features = Page.featured.online
    end
  end
  
end
