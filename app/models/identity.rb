class Identity
  include Mongoid::Document
  include OmniAuth::Identity::Models::Mongoid

  field :name, type: String
  field :password_digest, type: String
  validates_presence_of :name
  auth_key :name  
end
