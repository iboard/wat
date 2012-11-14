# -*- encoding : utf-8 -*-"
class TranslationsController < ApplicationController

  before_filter :ensure_translator_facility

  def index
    @translations = TRANSLATION_STORE
  end

  def show
    @translations = TRANSLATION_STORE
    render :index
  end


  # {"translation"=>{"locale"=>"en", "key"=>"close", "value"=>"close"}, "action"=>"create", "controller"=>"translations"}):
  def create
    @locale =  params[:translation][:locale]
    @key = params[:translation][:key]
    @value = save_by_key(@locale, @key, params[:translation][:value])
  end

  private
  def ensure_translator_facility
    redirect_to signin_path, alert: t(:access_denied) unless can_read?('Locale Admin')
  end

  def save_by_key(locale, key, value)
    I18n.backend.store_translations(locale, {key => value}, :escape => false)
    value
  end

  def prepare_locale_value_for_js(locale,key)
    _locale=I18n.locale
    I18n.locale = locale
    _rc = (_in = I18n.t(key.to_sym)).class == Hash ? combine_store_keys(locale,key,_in) : _in
    I18n.locale=_locale
    _rc
  end
  helper_method :prepare_locale_value_for_js

  def combine_store_keys(locale,key,_in)
    _zero = I18n.backend.backends.first.store.get( [locale,key,"zero"].join('.') )
    if _zero
      _one   = I18n.backend.backends.first.store.get( [locale,key,"one"].join('.') )
      _other = I18n.backend.backends.first.store.get( [locale,key,"other"].join('.') )
      { :zero => _zero, :one => _one, :other => _other }.to_json
    else
      _in.to_json
    end
  end

end