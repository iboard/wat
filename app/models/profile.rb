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

  field :is_public, type: Boolean, default: true

  after_create :create_timeline_events_for_create
  after_update :create_timeline_events_for_update

  protected

  def create_timeline_events_for_create
    create_user_event("created")
    create_admin_event("created")
  end

  def create_timeline_events_for_update
    create_user_event("updated")
    create_admin_event("updated")
  end

  def create_user_event(_what)
    Timeline.find_by(name: self.user.name).create_event( {  message: "#{_what}_your_profile", sender_id: self.user._id }, UserEvent )
  end

  def create_admin_event(_what)
    AdminTimeline::profile_changed( self.user, _what )
  end

end
