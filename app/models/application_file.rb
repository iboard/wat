class ApplicationFile
  include Mongoid::Document
  include Mongoid::Paperclip

  unless defined?( SUPPORTED_IMAGES_REGEX )
    SUPPORTED_IMAGES_REGEX = ["image/jpeg", "image/png", "image/gif"]
  end

  has_mongoid_attached_file :file, :styles =>  {
    :avatar  => "128x128#",
    :popup   => "640x480#",
    :small   => "128x128=",
    :large   => "300x300#",
    :thumb  => "100x100#",
    :icon   => "64x64#",
    :tiny   => "32x32#"
  }

  before_post_process :image?

  embedded_in :attachment

private
  def image?
    SUPPORTED_IMAGES_REGEX.include?(file_content_type)
  end

end