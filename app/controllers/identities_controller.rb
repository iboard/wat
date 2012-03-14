# -*- encoding : utf-8 -*-
class IdentitiesController < ApplicationController
  def new
    @identity = env['omniauth.identity']
  end
end
