# -*- encoding : utf-8 -*-
class AttachmentsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :load_resources

  def index
    @attachments ||= Attachment.where( user_id: @user._id )
    @attachment ||= UserAttachment.new(user_id: @user._id )
  end

  def new
    @attachment = @user.attachments.build()
    @attachment.application_file ||= ApplicationFile.new( attachment: @attachment )
    respond_to do |format|
      format.js {
        render 'shared/new_attachment'
      }
    end
  end

  def create
    @attachment = @user.attachments.create(params[:attachment][:application_file])
    _ok = @attachment.save && @user.save
    @attachments = @attachment.user.attachments
    if _ok
      respond_to do |format|
        format.js {
          render 'shared/create_attachment'
        }
      end
    else
      redirect_to user_attachments_path(@user), alert: t(:file_not_uploaded, filename: file_name, error: @attachment.errors.full_messages)
    end
  end

  def edit
  end

  def update
    if @attachment.create_or_replace_file(params[:attachment][:application_file])      
      redirect_to user_attachments_path(@user), notice: t(:file_stored_successfully)
    else
      render :edit
    end
  end

  def destroy
    file_name = @attachment.file_name
    if @attachment.delete
      @user.save!
      @attachments = @attachment.user.attachments
      respond_to do |format|
        format.html {
          redirect_to user_attachments_path(@user), notice: t(:file_deleted, filename: file_name)
        }
        format.js {
          render 'shared/destroy_attachment'
        }
      end
    else
      redirect_to user_attachments_path(@user), alert: t(:file_not_deleted, filename: file_name, error: @attachment.errors.full_messages)
    end
  end

  def upload_finished
    render 'shared/finished_attachment'
  end

private
  def load_resources
    @user = current_user
    @attachment = Attachment.where(user_id: @user.id).find(params[:id]) if params[:id].present?
  end
end