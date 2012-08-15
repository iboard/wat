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
    if allow_destroy?
      super.tap do
        clean_file
      end
    end
  end

  def destroy_file!
    if allow_destroy?
      clean_file
    end
    file.nil?
  end

  def create_or_replace_file(params_hash)
    if self.application_file
      self.application_file.update_attributes(params_hash)
    else
      self.create_application_file(params_hash)
    end
  end

private
  def clean_file
    application_file.destroy if file && application_file
  end

  # before_destroy filters doesn't work in MongoID 2.4.x
  # https://github.com/mongoid/mongoid/issues/1997
  # The allow_destroy? call is a workaround for this bug
  # and allows to overwrite allow_destroy? in derivations.
  def allow_destroy?
    true
  end

end