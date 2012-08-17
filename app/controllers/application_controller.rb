# -*- encoding : utf-8 -*-

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :ensure_locale
  before_filter :setup_timeline

  helper_method :current_user
  helper_method :user_signed_in?
  helper_method :correct_user?
  helper_method :authenticate_admin!
  helper_method :can_read?
  helper_method :can_write?
  helper_method :can_execute?
  helper_method :param_to_class
  helper_method :class_to_param


private
  def current_user
    return $CURRENT_USER if Rails.env == 'test' && $CURRENT_USER.present? && $CURRENT_USER
    begin
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    rescue Mongoid::Errors::DocumentNotFound
      nil
    end
  end

  def user_signed_in?
    return true if current_user
  end
  
  def correct_user?
    @user = User.find(params[:id]) unless params[:id].blank?

    session[:login_for_request] ||= request.fullpath.inspect unless current_user
    unless @user && current_user == @user
      redirect_to signin_path, :alert => "Access denied."
    end
  end
  
  def authenticate_user!
    if !current_user
      session[:login_for_request] ||= request.fullpath.inspect
      redirect_to signin_path, :alert => t(:you_need_to_sign_in)
    end
  end
  
  def authenticate_admin!
    session[:login_for_request] ||= request.fullpath.inspect unless current_user
    unless current_user && current_user.can_execute?('Admin')
      redirect_to signin_path, :alert => t(:access_denied)
    end
  end

  def authenticate_author!
    session[:login_for_request] ||= request.fullpath.inspect unless current_user
    unless current_user && current_user.can_execute?('Admin', 'Author')
      redirect_to signin_path, :alert => t(:access_denied)
    end
  end
  
  def can_read?(*what)
    current_user && current_user.can_read?(*what)
  end
  
  def can_write?(*what)
    current_user && current_user.can_write?(*what)
  end
  
  def can_execute?(*what)
    current_user && current_user.can_execute?(*what)
  end
  
  def ensure_locale
    set_locale = I18n.default_locale
    unless Settings.multilanuage == false
      session[:locale] ||= cookies[:locale]
      if session[:locale]
        set_locale = session[:locale]
      else
        set_locale = try_to_set_from_client(set_locale)
      end
    end
    session[:locale] = set_locale
    cookies.permanent[:locale] = set_locale
    I18n.locale = set_locale
  end


  def try_to_set_from_client(default)
    set_locale = default
    if request.env['HTTP_ACCEPT_LANGUAGE'].present?
      client_locale = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
      if I18n.available_locales.include?(client_locale.to_sym)
        set_locale = client_locale.to_sym
        flash.now[:info] = %{
          <strong>Language #{I18n.translate(set_locale.to_sym)} selected</strong>
          <br/>
          We've tried to set the language of this site to the language provided by your browser.
          You may change the language at the bottom of the page. We provide English and German.
          <br/><br/>
          <strong>Es wurde die Sprache #{I18n.translate(set_locale.to_sym)} ausgewählt</strong>
          <br/>
          Wir haben versucht die Sprache dieser Website anhand der Angaben ihres Browsers zu setzen.
          Sie können die Sprache am Ende der Seite umstellen. Wir stellen Englisch und Deutsch zur Verfügung.
        }.html_safe
      end
    end
    set_locale
  end

  def class_to_param(_object)
    _object.class.to_s.underscore
  end

  def param_to_class(param)
    param.camelize.constantize
  end

  def setup_timeline
    session[:timeline] ||= { display: :show, timelines: :all }
    @timeline_display = session[:timeline][:display] == :show ? 'icon-chevron-down' : 'icon-chevron-up'
    Doorkeeper.configure do |doorkeeper|
      doorkeeper.doorkeeper = Doorkeeper::TimelineLogger.new
      doorkeeper.timeline.reload
    end
  end



protected


  def ckeditor_authenticate
    authenticate_author!
  end

  # Set current_user as assetable
  # def ckeditor_before_create_asset(asset)
  #   asset.assetable = current_user
  #   return true
  # end

end
