# -*- encoding : utf-8 -*-
class HomeController < ApplicationController
  
  def index
    if can_read?('Admin', 'Maintainer')
      @hero = Page.where(_id: 'hero').first
      @features = Page.featured
    else
      @hero = Page.online.where(_id: 'hero').first
      @features = Page.featured.online
    end
  end
  
end
