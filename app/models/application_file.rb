class ApplicationFile
  include Mongoid::Document
  include Mongoid::Paperclip

  has_mongoid_attached_file :file

  embedded_in :attachment
end