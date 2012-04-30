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
        #redirect_to user_path(@user), notice: t(:avatar_saved_successfully)
        render :crop_avatar
      }
      format.js {}
    end
  end

  def create
    @avatar = @user.create_avatar params[:avatar]
    @user.save!
    redirect_to user_path(@user), notice: t(:avatar_saved_successfully)
  end

  def crop_avatar
    if is_in_crop_mode?
      if @user.avatar.update_attributes(params[:avatar])
        @user.save!
        if params[:avatar][:crop_x].present?
          @user.avatar.avatar.reprocess!
        end
      end
      redirect_to user_path(@user), :error => @user.errors.map(&:to_s).join("<br />")
    end
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

  def is_in_crop_mode?
    params[:avatar] &&
    params[:avatar][:crop_x] && params[:avatar][:crop_y] &&
    params[:avatar][:crop_w] && params[:avatar][:crop_h]
  end


end