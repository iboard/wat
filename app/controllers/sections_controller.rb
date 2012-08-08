class SectionsController < ApplicationController

  before_filter :authenticate_admin!, except: [:show]

  def new
    @section = Section.new(permalink: Time.now.strftime("%Y%m%d%H%M%S"))
  end

  def index
    @sections = Section.all
  end

  def create
    @section = Section.create(params[:section])
    if @section.valid?
      redirect_to sections_path, notice: t(:section_successfully_created)
    else
      render :new
    end
  end

  def edit
    @section = Section.find(params[:id])
  end

  def update
    @section = Section.find(params[:id])
    if @section.update_attributes(params[:section])
      redirect_to sections_path, notice: t(:section_successfully_updated)
    else
      render :edit
    end
  end

  def destroy
    @section = Section.find(params[:id])
    if @section.delete
      msg = {notice: t(:section_successfully_deleted)}
    else
      msg = {alert: t(:cannot_delete, what: t(:section))}
    end
    redirect_to sections_path, msg
  end
  
  def show
    @section = Section.find(params[:id])
    if can_read?('Admin', 'Maintainer')
      redirect_to @section.pages.first || root_path
    else
      redirect_to @section.pages.online.first || root_path
    end
  end

  def sort
    @sections = Section.all
  end

  def update_sort
    analyze_params.each_with_index do |id,idx|
      section = Section.find(id)
      section.position = idx
      section.save!
    end
    render :nothing => true
  end

private
  # @todo: this works only with onewordpermakey not with one-word-permakey unless all params have the same count of dashes!
  def analyze_params
    ordered_items = []
    items = params
    items.delete(:action)
    items.delete(:controller)
    items.each do |key, item|
      name = key.gsub(/ordered_items_/,'')
      if item.count == 1
        name += "-" + item.first
        ordered_items += [name]
      else
        ordered_items += item
      end
    end
    Rails.logger.info "SORTED #{ordered_items.inspect}"
    ordered_items
  end
  
end