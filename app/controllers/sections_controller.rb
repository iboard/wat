class SectionsController < ApplicationController
  
  def show
    @section = Section.find(params[:id])
    redirect_to @section.pages.first || root_path
  end
  
end