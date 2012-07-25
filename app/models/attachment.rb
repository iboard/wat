class Attachment
  include Mongoid::Document
  embeds_one :application_file, cascade_callbacks: true


  def file
    self.application_file.file if self.application_file
  end

  def file=(_file)
    self.application_file = ApplicationFile.new(file: _file)
  end

  def path
    self.application_file.file.path
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
    application_file.destroy
  end

end