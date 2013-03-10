# -*- encoding : utf-8 -*-

class ProfilesController < ApplicationController

  before_filter :ensure_user, except: [:show]

  def show
    @user = User.find(params[:user_id])
    respond_to do |format|
      format.html { }
      format.js {
        render nothing: true unless current_user && @user == current_user
      }
    end
  end

  def edit
  end

  def new
    @user.build_profile
  end

  def create
    @user.create_profile(params[:profile])
  end

  def update
    begin 
      @user.profile.update_attributes(params[:profile])
      @user.save
    rescue => e
      @user.profile.errors.add(:dob, e.message.inspect)
      render :edit
    end
  end

  def destroy
    @user.profile = nil
    @user.save!
  end


private
  def ensure_user
    @user = User.find(params[:user_id])
    unless (current_user && current_user == @user) || can_read?('Admin')
      redirect_to root_path, alert: t(:access_denied)
    end
  end
end
