# -*- encoding : utf-8 -*-"
class TranslationsController < ApplicationController

  before_filter :ensure_translator_facility

  def index
    @translations = TRANSLATION_STORE
  end

  # {"translation"=>{"locale"=>"en", "key"=>"close", "value"=>"close"}, "action"=>"create", "controller"=>"translations"}):
  def create
    @locale =  params[:translation][:locale]
    @key = params[:translation][:key]
    @value = params[:translation][:value]
    I18n.backend.store_translations(@locale, {@key => normalize_key(@value)}, :escape => false)
  end

  private
  def normalize_key(_input)
    begin
      _hash = eval( _input )
      _hash
    rescue
      _input
    end
  end

  def ensure_translator_facility
    redirect_to signin_path, alert: t(:access_denied) unless can_read?('Locale Admin')
  end
end