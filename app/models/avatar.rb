class Avatar
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip


  def self.css_size_for(_size)
    case _size
      when :avatar
        "width: 128px; height: 128px;"
      when :large
        "width: 300px; height: 300px;"
      when :thumb
        "width: 100px; height: 100px;"
      when :icon
        "width: 64px; height: 64px;"
      else
        "width: 32px; height: 32px;"
    end
  end

  field :use_gravatar, type: Boolean, default: false
  embedded_in :user

  attr_accessor :crop_x,:crop_y,:crop_w,:crop_h

  has_mongoid_attached_file :avatar,
                            styles: {
                              avatar: "128x128>",
                              large: "300x300>",
                              thumb: "100x100=",
                              icon: "64x64=",
                              tiny: "32x32="
                            },
                            processors: [:cropper]
  after_update  :reprocess_avatar

  def cropping?
    !@reprocessed && !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  # Avatar or Gravatar path
  def picture(style=:icon)
    self.use_gravatar ? gravatar_path(style) : avatar.url(style)
  end

  def avatar_geometry(style = :large)
    Paperclip::Geometry.from_file(self.avatar.path(style)).to_s.split(/x/).map(&:to_i)
  end

  def original
    avatar_geometry(:original).first
  end

  def large
    avatar_geometry(:large).first
  end

  def original=(ignore)
  end

  def large=(ignore)
  end

  private
  def reprocess_avatar
    if cropping? && !@reprocessed
      @reprocessed = true
      avatar.reprocess!
    end
  end

end