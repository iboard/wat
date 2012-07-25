class Attachment
  include Mongoid::Document
  embeds_one :application_file, cascade_callbacks: true
  accepts_nested_attributes_for :application_file
  
  def file
    self.application_file.file if self.application_file
  end

  def file=(_file)
    self.application_file = ApplicationFile.new(file: _file)
  end

  def path
    self.application_file.file.path if self.application_file
  end

  def file_name
    File::basename(self.path) if self.path
  end

  def read
    File.read self.path
  end

  def delete
    clean_file
    super
  end

private
  def clean_file
    application_file.destroy if application_file
  end

end