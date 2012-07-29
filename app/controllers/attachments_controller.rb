# -*- encoding : utf-8 -*-
class AttachmentsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :load_resources

  def index
    @attachments ||= Attachment.where( user_id: @user._id )
  end

  def new
    @attachment = @user.attachments.build()
  end

  def create
    @attachment = @user.attachments.create(params[:application_file])
    if @attachment.save && @user.save
      redirect_to user_attachments_path(@user), notice: t(:file_stored_successfully)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @attachment.create_or_replace_file(params[:application_file])      
      redirect_to user_attachments_path(@user), notice: t(:file_stored_successfully)
    else
      render :edit
    end
  end

  def destroy
    file_name = @attachment.file_name
    if @attachment.delete
      @user.save!
      redirect_to user_attachments_path(@user), notice: t(:file_deleted, filename: file_name)
    else
      redirect_to user_attachments_path(@user), alert: t(:file_deleted, filename: file_name, error: @attachment.errors.full_messages)
    end
  end

private
  def load_resources
    @user = current_user
    @attachment = Attachment.where(user_id: @user.id).find(params[:id]) if params[:id].present?
  end
end