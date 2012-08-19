# -*- encoding : utf-8 -*-

# class ActionDispatch::Http::UploadedFile
#   include Paperclip::Upfile
# end
Paperclip.options[:image_magick_path] = Settings.image_magick_path || '/opt/local/bin'

require File::dirname(__FILE__) + "/../../lib/paperclip_processors/cropper.rb"
