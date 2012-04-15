class AvatarsController < ApplicationController

  before_filter :load_resources

  def new
    @avatar = @user.avatar
  end

  def show
    @avatar ||= @user.avatar || @user.build_avatar
    render :new
  end

  def update
    @avatar = @user.avatar.update_attributes(params[:avatar])
    @user.save!
    respond_to do |format|
      format.html {
        redirect_to user_path(@user), notice: t(:avatar_saved_successfully)
      }
      format.js {}
    end
  end

  def create
    @avatar = @user.create_avatar params[:avatar]
    @user.save!
    redirect_to user_path(@user), notice: t(:avatar_saved_successfully)
  end

  def destroy
    @user.avatar.delete
    @user.avatar = @user.build_avatar
    @user.save
  end

private
  def load_resources
    @user = User.find params[:user_id]
  end

end