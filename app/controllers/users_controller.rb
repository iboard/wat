class UsersController < ApplicationController

  before_filter :authenticate_user!, :only => [:edit, :update, :show]
  before_filter :correct_user?, :only => [:edit, :update, :show]

  def index
    @users = User.all
    if current_user
      flash.now[:info] = t(:home_info_logged_in)
    else
      flash.now[:info] = t(:home_info_logged_out)
    end
  end

  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      redirect_to @user, :notice => t(:user_successfully_updated)
    else
      flash.now[:alert]= t(:cannot_save_user)
      render :edit
    end
  end


  def show
    @user = User.find(params[:id])
  end

  def destroy
    @user = User.find(params[:id])
    @user.authentications.delete_all
    @user.delete
    redirect_to signout_path, :notice => t(:user_successfully_deleted)
  end

end
