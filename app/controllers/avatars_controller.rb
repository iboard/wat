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
        crop_or_show
      }
      format.js {}
    end
  end

  def create
    @avatar = @user.create_avatar params[:avatar]
    @user.save!
    respond_to do |format|
      format.html {
        crop_or_show
      }
      format.js {}
    end
  end

  def crop_avatar
    if is_in_crop_mode?
      if @user.avatar.update_attributes(params[:avatar])
        @user.avatar.avatar.reprocess! if @user.avatar.cropping?
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

  def load_resources
    @user = User.find params[:user_id]
  end

  def is_in_crop_mode?
    params[:avatar] &&
    params[:avatar][:crop_x] && params[:avatar][:crop_y] &&
    params[:avatar][:crop_w] && params[:avatar][:crop_h]
  end

  def crop_or_show
    if params[:avatar][:avatar].present?
      render :crop_avatar
    else
      redirect_to user_path(@user)
    end
  end

end