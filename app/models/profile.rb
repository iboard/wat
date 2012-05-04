class Profile
  include Mongoid::Document
  embedded_in :user

  field :firstname
  field :lastname
  field :dob, type: Date
  field :phone_number
  field :mobile

  field :twitter_handle
  field :facebook_profile
  field :google_uid

end