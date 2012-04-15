class Avatar
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip


  field :use_gravatar, type: Boolean, default: false
  embedded_in :user

  has_mongoid_attached_file :avatar,
                            :styles => {
                              :avatar  => "128x128=",
                              :large   => "300x300=",
                              :thumb  => "100x100=",
                              :icon   => "64x64="
                            },
                            :processors => [:cropper]
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  after_update  :reprocess_avatar, :if => :cropping?


  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  def avatar_geometry(style = :original)
    paperclip_geometry avatar, style
  end

  def new_avatar?
    if avatar.updated_at && ((Time::now() - Time::at(self.avatar.updated_at)) < 1.minute)
      self.use_gravatar = false
      save
      true
    else
      false
    end
  end

private
  def reprocess_avatar
    avatar.reprocess!
  end

  def avatar_geometry(style = :original)
    paperclip_geometry avatar, style
  end
end