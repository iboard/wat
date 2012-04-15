class Profile
  include Mongoid::Document
  embedded_in :user

  field :firstname
  field :lastname
  field :dob, type: Date
  field :phone_number
  field :mobile
  field :use_gravatar, type: Boolean, default: false

end