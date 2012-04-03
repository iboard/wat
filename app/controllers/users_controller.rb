# -*- encoding : utf-8 -*-
class UsersController < ApplicationController

  before_filter :authenticate_user!, :only => [:edit, :show]
  before_filter :correct_user?, :only => [:edit,:show]
  before_filter :correct_user_or_reset_token?, only: [:update]

  before_filter :parse_search_param, only: [:index]

  def index
    if can_read?('Admin')
      @users ||= User.asc(:name)
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
    if params[:user][:password_reset_token].present?
      if create_or_update_authentication
        redirect_to signin_path, notice: t(:password_set)
      else
        flash.now[:alert] =@identity.errors.full_messages.join("<br/>".html_safe)
        render :reset_password
      end
    else
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
  end

  def show
    @user = User.find(params[:id])
  end

  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      redirect_to signout_path, :notice => t(:user_successfully_deleted)
    else
      redirect_to user_path(@user), alert: t(:can_not_delete_user, why: @user.errors.full_messages.join(" & "))
    end
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

  def resend_confirmation_mail
    @user = User.find(params[:id])
    UserMailer.registration_confirmation(@user).deliver
    redirect_to root_path, :notice => t(:please_confirm_your_address, :address => @user.email)
  end

  def auth_providers
    @user = User.find(params[:id])
  end

  def personal_information 
    @user = User.find(params[:id])
  end



  # GET '/users/forgot_password'
  def forgot_password
    # Render the form to reset password (enter email)
  end

  # PUSH '/users/send_password_token'
  def send_password_reset_token
    @user = User.where(email: /#{params[:email]}/i).first
    if @user
      @user.reset_password
      redirect_to root_path, notice: t(:please_check_your_inbox_for, email: @user.email)
    else
      redirect_to forgot_password_users_path, alert: t(:email_not_found)
    end
  end

  # GET '/users/:id/reset_password/:token 
  def reset_password
    @user = User.find(params[:id])
    unless @user.password_reset_token == params[:token]
      redirect_to signin_path, alert: t(:wrong_token)
    end
  end

private
  def parse_search_param
    if params[:search].present?
      _p = params[:search].is_a?(String) ? JSON.parse( params[:search] ) : params[:search]
      @search = Search.new( search_text: _p['search_text'], search_controller: _p['search_controller'] )
      @users = User.any_of(
        {name: /#{@search.search_text}/i}, 
        {email: /#{@search.search_text}/i}
      ).asc(:name)
    else
      @search = Search.new search_text: '', search_controller: 'users'
    end
  end      

  def correct_user_or_reset_token?
    unless params[:user][:password_reset_token].present?
      correct_user?
    else
      _user = User.where(password_reset_token: params[:user][:password_reset_token]).first
      unless _user    
        flash.now[:alert] = t(:wrong_token)
        @user ||= User.find(params[:id])
        render :reset_password
      else
        @user = _user
      end
    end
  end

  def create_or_update_authentication
    auth = @user.authentications.where(provider: 'identity').first
    @identity = Identity.where(name: @user.name).first
    
    unless @identity
      @identity = Identity.create(name: @user.name)
      auth = @user.authentications.create(provider: 'identity', uid: @identity.id.to_s)
    end

    auth = @user.authentications.find_or_create_by provider: 'identity', uid: @identity.id.to_s
    
    unless @identity.nil?
      @identity.update_attributes(password: params[:user][:password], password_confirmation: params[:user][:password_confirmation])
      unless @identity.save
        return false
      end
    end
    @user.password_reset_token = nil
    @user.save!
  end
end
