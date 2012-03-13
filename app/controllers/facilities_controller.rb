class FacilitiesController < ApplicationController

  before_filter :authenticate_admin!
  before_filter :load_user

  def index
  end

  def create
    @user.facilities.create(params[:facility])
    if @user.valid?
      redirect_to user_facilities_path(@user), :notice => t(:facility_successfully_added)
    else
      redirect_to user_facilities_path(@user), :alert => t(:facility_could_not_be_added, errors: @user.errors.full_messages.join(", "))
    end
  end

  def destroy
    @user.facilities.find(params[:id]).delete
    redirect_to user_facilities_path(@user), :notice => t(:facility_successfully_removed)
  end


private
  def load_user
    @user = User.find(params[:user_id])
  end
end
