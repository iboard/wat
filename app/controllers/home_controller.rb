class HomeController < ApplicationController
  def index
    @hero = Page.where(_id: 'hero').first
    @features = Page.where(title: /^\@/)
  end
end
