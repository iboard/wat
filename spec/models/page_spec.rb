require 'spec_helper'

describe Page do

  it "uses permalink as key" do
    page = Page.new(:permalink => 'This is Page One', :title => "This is page one")
    page.save
    _page = Page.find("this-is-page-one")
    assert _page.eql?(page), "Page should be addressed by key"
  end

  it "can have a banner" do
    page = Page.new(:permalink => 'This is Page One', :title => "This is page one")
    page.create_banner(banner_file_name: 'testbanner.png')
    page.save!
    page.reload
    page.banner.banner_file_name.should == 'testbanner.png'
  end

  it "lists all pages with banners for the top-page carousel" do
    page0 = Page.create(:permalink => 'wo banner', title: "No Banner here")
    page0.save!
    
    page1 = Page.create(:permalink => 'This is Page One', :title => "This is page one")
    page1.create_banner(banner_file_name: 'testbanner.png')
    page1.banner.banner = File.new(PICTURE_FILE_FIXTURE)
    page1.save!
    
    page2 = Page.create(:permalink => 'This is Page two', :title => "This is page one")
    page2.create_banner(banner_file_name: 'avatar.jpg')
    page2.banner.banner = File.new(PICTURE_FILE_FIXTURE)
    page2.save!
    
    page3 = Page.create(:permalink => 'This is Page three', :title => "File not uploaded example")
    page3.create_banner(banner_file_name: 'avatar.jpg')
    page3.save!
    
    Page.with_banner.map(&:_id).should == ['this-is-page-two', 'this-is-page-one' ]
  end

end
