require 'spec_helper'

describe UserAttachment do

  it "stores files for the user" do
    user = test_user "Max Muster", "secret",['private attchments'],true
    attachment = user.attachments.create( file: File.new(TEXT_FILE_FIXTURE) )
    attachment.class.should == UserAttachment
    File.read(_path=attachment.path).should match /Testfile Signature/
    user.attachments.destroy_all
    File.exist?(_path).should be_false
  end
  
end
