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

  it "delegates to the ApplicationFile" do
    attachment = Attachment.create(application_file: ApplicationFile.new(file: File.new( TEXT_FILE_FIXTURE )))

    attachment.read.should match /Testfile Signature/
    attachment.file_name.should == File::basename( TEXT_FILE_FIXTURE )
  end

  describe "if the file exists" do

    before(:each) do
      @attachment = Attachment.create(application_file: ApplicationFile.new(file: File.new( TEXT_FILE_FIXTURE )))
    end
    
    it "can remove the file" do
      _path = @attachment.path
      @attachment.destroy_file!
      File.exist?(_path).should be_false
    end
  
    it "can update/replace an existing file" do
      _path = @attachment.path
      params = { application_file: { file: File.new(PICTURE_FILE_FIXTURE) } }
      @attachment.create_or_replace_file(params[:application_file])
      @attachment.path.should match File::basename(PICTURE_FILE_FIXTURE)
      File.exist?(_path).should be_false
    end
  end

  describe "if the file doesn't exist" do
    before(:each) do
      @attachment = Attachment.create(application_file: ApplicationFile.new())
      @path = @attachment.path
      @path.should be_nil
    end
    
    it "can call to remove the file without exception" do
      @path = @attachment.path
      @attachment.destroy_file! # shouldn't raise an exeption
      @attachment.path.should be_nil
      @attachment.file.url.should match "missing.png"
    end
  
    it "creates the file on call to update/replace file doesn't exist" do
      params = { application_file: { file: File.new(PICTURE_FILE_FIXTURE) } }
      @attachment.create_or_replace_file(params[:application_file])
      @attachment.path.should match File::basename(PICTURE_FILE_FIXTURE)
    end
  end

end