require 'spec_helper'

describe AttachmentsController do

  describe "for anonymous sessions" do
    it "doesn't render the index page" do
      visit attachments_path
      page.should have_content "You need to sign in for access to this page."
    end
  end

  describe "for authenticated users" do

    before(:each) do
      @user = test_user "Hugo Gans", "munic"
      sign_in_user name: "Hugo Gans", password: "munic"
    end

    it "shows an index-page" do
      @user.attachments.create(file: File.new(TEXT_FILE_FIXTURE))
      visit user_attachments_path(@user)
      page.should have_content "#{@user.name}'s files"
      page.should have_link File::basename(TEXT_FILE_FIXTURE)
      page.should have_content "text/plain"
      page.should have_content "19 Bytes"
    end

    it "displays text-file-attachments" do
      @user.attachments.create(file: File.new(TEXT_FILE_FIXTURE))
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

    it "let the user upload a file" do
      click_link "Your files ..."
      test_file = TEXT_FILE_FIXTURE
      page.should have_content I18n.t(:number_of_your_files, count: 0)
      click_link "Upload file"
      attach_file("application_file_file", test_file)
      click_button("Upload file")
      page.should have_content File::basename(TEXT_FILE_FIXTURE)
      page.click_link File.basename(TEXT_FILE_FIXTURE)
      page.should have_content "Testfile Signature"
    end

    it "let the user upload a new file" do
      @user.attachments.create(file: File.new(TEXT_FILE_FIXTURE))
      _path = @user.attachments.first.path
      visit user_attachments_path(@user)
      click_link "Replace"
      attach_file("application_file_file", File.join(Rails.root,'fixtures', 'avatar.jpg'))
      click_button("Upload file")
      page.should have_content 'avatar.jpg'
      page.should have_content '3 KB'
    end

  end
end
