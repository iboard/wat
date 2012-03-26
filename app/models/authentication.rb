# -*- encoding : utf-8 -*-
class Authentication
  include Mongoid::Document
  field :provider, :type => String
  field :uid, :type => String
  
  embedded_in :user

  after_destroy :remove_identity

private
  def remove_identity
    if self.provider == 'Identity'
      Identity.where(uid: self.uid).delete_all
    end
  end

end