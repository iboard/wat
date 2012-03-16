# -*- encoding : utf-8 -*-

class PagesController < ApplicationController

  def index
    unless can_execute?("Admin")
      redirect_to root_path, :alert => t(:access_denied)
    else
      @pages = Page.asc(:title)
    end
  end
  
  def show
    begin
      @page = Page.find(params[:id])
    rescue => e
      @page = nil
    end
  end

  def new
    @page = Page.new permalink: ''
  end

  def create
    if params[:commit] == t(:cancel)
      redirect_to root_path, :notice => t(:canceled)
    elsif !can_write?('Admin')
      redirect_to root_path, :alert => t(:access_denied)
    else
      @page = Page.create(params[:page])
      if @page.valid?
        redirect_to @page, :notice => t(:page_successfully_created)
      else
        render :new
      end
    end
  end

  def edit
    @page = Page.find(params[:id])
    unless can_write?('Admin')
      redirect_to @page, :alert => t(:you_not_allowed_to_edit_this_page)
    end
  end

  def update
    @page = Page.find(params[:id])
    if params[:commit] == t(:cancel)
      redirect_to @page, :notice => t(:nothing_changed)
      return
    end
    
    unless can_write?('Admin')
      redirect_to @page, :alert => t(:you_not_allowed_to_edit_this_page)
    else
      if @page.update_attributes(params[:page])
        redirect_to @page, :notice => t(:page_successfully_updated)
      else
        render :edit
      end
    end
  end

  def destroy
    @page = Page.find(params[:id])
    unless can_execute?('Admin')
      redirect_to @page, :notice => t(:access_denied)
    else
      @page.delete
      redirect_to root_path, :notice => t(:page_successfully_deleted)
    end
  end
end
