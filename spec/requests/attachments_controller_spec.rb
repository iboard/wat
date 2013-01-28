require 'spec_helper'

describe AttachmentsController do

  before(:all) do
    @test_attachments = []
    Attachment.delete_all
    Attachment.count().should == 0
  end

  after(:all) do
    @test_attachments.each do |attachment|
      attachment.delete
    end
    Attachment.count().should == 0
  end

  describe "for anonymous sessions" do
    it "doesn't render the index page" do
      visit attachments_path
      page.should have_content "You need to sign in for access to this page."
    end
  end

  describe "for authenticated users" do

    before(:each) do
      @user = test_user "Hugo Gans", "munic"
      visit switch_language_path(:en)
      sign_in_user name: "Hugo Gans", password: "munic"
    end

    it "shows an index-page" do
      @test_attachments << @user.attachments.create(file: File.new(TEXT_FILE_FIXTURE))
      visit user_attachments_path(@user)
      page.should have_content "#{@user.name}'s files"
      page.should have_link File::basename(TEXT_FILE_FIXTURE)
      page.should have_content "text/plain"
      page.should have_content "19 Bytes"
    end

    it "displays text-file-attachments" do
      @test_attachments << @user.attachments.create(file: File.new(TEXT_FILE_FIXTURE))
      visit user_attachments_path(@user)
      click_link File::basename(TEXT_FILE_FIXTURE)
      page.should have_content "Testfile Signature"
    end

    it "deletes attachments" do
      @user.attachments.create(file: File.new(TEXT_FILE_FIXTURE))
      _path = @user.attachments.first.path
      visit user_attachments_path(@user)
      click_link "Delete"
      page.should have_content "File '#{File.basename(TEXT_FILE_FIXTURE)}' deleted"
      @user.attachments.count.should == 0
      File.exist?(_path).should be_false
    end

    it "shows a 'your files' link in the user-menu" do
      page.should have_link "Your files"
    end

    it "let the user upload a file", js: true do
      click_link "Your files ..."
      test_file = TEXT_FILE_FIXTURE
      page.should have_content I18n.t(:number_of_your_files, count: 0)
      attach_file("user_attachment_file", test_file)
      page.should have_link File.basename(TEXT_FILE_FIXTURE)
      @test_attachments << @user.attachments.last
    end

    it "let the user replace file" do
      @user.attachments.create(file: File.new(TEXT_FILE_FIXTURE))
      _path = @user.attachments.first.path
      visit user_attachments_path(@user)
      click_link "Replace"
      attach_file("application_file_file", File.join(Rails.root,'fixtures', 'avatar.jpg'))
      click_button("Upload file")
      page.should have_content 'avatar.jpg'
      page.should have_content '117 KB'
      click_link "Delete"
      if _path
        File.exist?(_path).should be_false
      end
    end

    it "let the user upload NO file" do
      @user.attachments.create()
      _path = @user.attachments.first.path
      _path.should be_nil

      visit user_attachments_path(@user)
      click_link "Delete"
      page.should_not have_content "ERROR"
      page.should have_content I18n.t(:file_deleted, filename: '')
      Attachment.count.should == 0
    end

  end
end
