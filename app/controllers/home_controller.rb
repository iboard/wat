# -*- encoding : utf-8 -*-
class HomeController < ApplicationController
  def index
    @hero = Page.where(_id: 'hero').first
    @features = Page.where(permalink: /^\@/)
  end
end
