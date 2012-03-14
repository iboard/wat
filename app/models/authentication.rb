# -*- encoding : utf-8 -*-
class Authentication
  include Mongoid::Document
  field :provider, :type => String
  field :uid, :type => String
  
  embedded_in :user
end