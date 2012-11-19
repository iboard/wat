# -*- encoding : utf-8 -*-

class PagesController < ApplicationController

  _allow_index_actions = Settings.supress_global_search == true ? [:show] : [:show, :index, :autocomplete_search]
  before_filter :authenticate_user!, except: _allow_index_actions
  before_filter :authenticate_admin!, except: [:index, :show, :autocomplete_search]
  before_filter :set_last_modifier, only: [:create, :update]

  before_filter :parse_search_param, only: [:index]

  def index
    @pages_to_show = nil if !params[:page].present?
    _pp = Settings.paginate_pages_per_page || 4
    @pages_to_show ||= (@searched_pages ? @searched_pages : permitted_pages )
    redirect_to signin_path, alert: t(:you_need_to_sign_in) if !@pages_to_show
    @pages ||= @pages_to_show.asc(:position).paginate( page: (params[:page] ? params[:page] : 1), per_page: _pp )
  end
  
  def show
    begin
      @page = permitted_pages.find(params[:id])
    rescue => e
      if Page.find(params[:id])
        redirect_to signin_path, alert: t(:you_need_to_sign_in)
      else
        raise e
      end
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
    @page = permitted_pages.find(params[:id])
    unless can_write?('Admin')
      redirect_to @page, :alert => t(:you_not_allowed_to_edit_this_page)
    end
  end

  def update
    @page = permitted_pages.find(params[:id])
    if params[:commit] == t(:cancel)
      redirect_to @page, :notice => t(:nothing_changed)
      return
    end
    
    unless can_write?('Admin')
      redirect_to @page, :alert => t(:you_not_allowed_to_edit_this_page)
    else
      params[:page].merge! saved_from_controller: true
      if @page.update_attributes(params[:page])
        redirect_to @page, :notice => t(:page_successfully_updated)
      else
        render :edit
      end
    end
  end

  def destroy
    @page = permitted_pages.find(params[:id])
    unless can_execute?('Admin')
      redirect_to @page, :notice => t(:access_denied)
    else
      @page.delete
      redirect_to pages_path, :notice => t(:page_successfully_deleted)
    end
  end

  def translate_to
    session[:locale] = params[:locale].to_sym
    redirect_to edit_page_path(params[:page_id], t(:language_changed_to, :lang => params[:locale]))
  end

  def read_translation_of
    @page = permitted_pages.find(params[:page_id])
    I18n.locale = params[:locale].to_sym
    render action: :show
  end

  def sort
    @pages = Page.all
    @pages.each_with_index do |p,i|
      p.sorting_id = i
    end
  end

  def update_sort
    params[:ordered_pages].each_with_index do |sid,idx|
      Page.where(sorting_id: sid).first.versionless do |_page|
        _page.update_attributes position: idx
      end
    end
    render :nothing => true
  end

  def restore_version
    @page = Page.find(params[:id])
    v = Version.new(@page,params[:version].to_i)
    if v.restore
      redirect_to @page, notice:  t(:version_restored, version: params[:version])
    else
      redirect_to @page,  alert:  t(:version_not_restored, version: params[:version])
    end
  end

  def autocomplete_search
    respond_to do |format|
       format.json { 
         render :json => permitted_pages.any_of({ title: /#{params[:q]}/i }, { body: /#{params[:q]}/i })
                             .only(:title).asc(:title)
                             .map{ |page| 
                               [
                                 :search_name => page.title, 
                                 :list_name => page.title
                               ]
                              }
                             .flatten
       }
     end
  end
  
private
  def parse_search_param
    if params[:search].present?
      _p = params[:search].is_a?(String) ? JSON.parse( params[:search] ) : params[:search]
      @search = Search.new( search_text: _p['search_text'], search_controller: _p['search_controller'] )
      @searched_pages = permitted_pages.any_of(
        {title: /#{@search.search_text}/i}, 
        {body: /#{@search.search_text}/i}
      )
    else
      @searched_pages = nil
      @search = Search.new search_text: '', search_controller: 'pages'
    end
  end

  def permitted_pages
    can_read?('Admin', 'Maintainer') ? Page.unscoped : Page.online
  end

  def set_last_modifier
    params[:page].merge! last_modified_by: current_user._id
  end
end
