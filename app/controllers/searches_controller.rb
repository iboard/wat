class SearchesController < ApplicationController

  def create
    @search = Search.new(params[:search])
    redirect_to eval("#{@search.search_controller.downcase.pluralize}_path(:search => @search.to_json)")
  end

end