require 'spec_helper'

describe Attachment do

  it "creates and removes an ApplicationFile" do
    # create
    attachment = Attachment.create(application_file: ApplicationFile.new(file: File.new( TEXT_FILE_FIXTURE )))
    attachment.application_file.save.should be_true
    File.read(attachment.path).should match /Testfile Signature/

    # remove (clean up)
    _path = attachment.path
    attachment.delete
    File.exist?(_path).should be_false
  end

  it "delegates read to the ApplicationFile" do
    attachment = Attachment.create(application_file: ApplicationFile.new(file: File.new( TEXT_FILE_FIXTURE )))
    attachment.read.should match /Testfile Signature/
  end

end