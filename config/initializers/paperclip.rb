# -*- encoding : utf-8 -*-

# class ActionDispatch::Http::UploadedFile
#   include Paperclip::Upfile
# end
if _path=Settings.image_magick_path
  Paperclip.options[:image_magick_path] = _path
end

require File::dirname(__FILE__) + "/../../lib/paperclip_processors/cropper.rb"
