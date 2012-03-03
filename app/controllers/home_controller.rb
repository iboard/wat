class HomeController < ApplicationController
  def index
    @users = User.all
    flash.now[:info] = t(:home_info)
  end
end
