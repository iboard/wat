# -*- encoding : utf-8 -*-
class UsersController < ApplicationController

  before_filter :authenticate_user!, :only => [:edit, :update, :show]
  before_filter :correct_user?, :only => [:edit, :update, :show]

  def index
    if can_execute?('Admin')
      @users = User.all
    else
      redirect_to root_path, :alert => t(:access_denied)
    end
  end

  def edit
    @user = User.find(params[:id])
    unless @user.valid? && @user.email
      flash.now[:info] = t(:please_enter_your_email_address)
    end
  end
  
  def update
    @user = User.find(params[:id])
    email_changed = @user.email != params[:user][:email]
    if @user.update_attributes(params[:user])
      if email_changed
        UserMailer.registration_confirmation(@user).deliver
        flash[:message] = t(:please_confirm_your_address, :address => @user.email)
      end
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

  def confirm_email
    @user = User.where(_id: params[:id], confirm_email_token: params[:token]).first
    if @user
      @user.confirm_email_token = nil
      @user.email_confirmed_at = Time.now.utc
      @user.save!
      redirect_to root_path, :notice => t(:email_confirmed)
    else
      redirect_to root_path, :alert => t(:token_not_found)
    end
  end

end
