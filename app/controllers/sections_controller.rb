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
    redirect_to @section.pages.first || root_path
  end
  
end