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

  field :invitation_token
  attr_accessor :invitation_token
  attr_accessible :invitation_token, :name, :password, :password_confirmation

  validates_with InvitationTokenValidator, on: :create

  def self.create(*args)
    record = super
    # Workaround bug in OmniAuth::Identity (reset lost attribute)
    record.invitation_token = args.first[:invitation_token] if Settings.public_sign_up == 'disabled'
    record
  end
end
