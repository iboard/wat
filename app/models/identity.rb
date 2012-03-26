# -*- encoding : utf-8 -*-
class Identity
  include Mongoid::Document
  include OmniAuth::Identity::Models::Mongoid

  field :name, type: String
  field :password_digest, type: String
  auth_key :name  

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :password, minimum: 5
  
end
