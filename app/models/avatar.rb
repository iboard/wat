class Avatar
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip


  field :use_gravatar, type: Boolean, default: false
  embedded_in :user

  attr_accessor :crop_x,:crop_y,:crop_w,:crop_h

  has_mongoid_attached_file :avatar,
                            :styles => {
                              :avatar  => "128x128>",
                              :large   => "300x300>",
                              :thumb  => "100x100=",
                              :icon   => "64x64=",
                              :tiny   => "32x32="
                            },
                            :processors => [:cropper]
  after_update  :reprocess_avatar, :if => :cropping?

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  def avatar_geometry(style = :large)
    Paperclip::Geometry.from_file(self.avatar.path).to_s.split(/x/).map(&:to_i)
  end

  def original
    avatar_geometry(:original).first
  end
  def large
    300
  end
  def original=(ignore)
  end
  def large=(ignore)
  end

private
  def reprocess_avatar
    avatar.reprocess!
  end

  
end