class HomeController < ApplicationController
  def index
    @users = User.all
    if current_user
      flash.now[:info] = t(:home_info_logged_in)
    else
      flash.now[:info] = t(:home_info_logged_out)
    end
  end
end
