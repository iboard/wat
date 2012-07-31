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
    page1.save!
    page2 = Page.create(:permalink => 'This is Page two', :title => "This is page one")
    page2.create_banner(banner_file_name: 'avata.jpg')
    page2.save!
    Page.with_banner.map(&:_id).should == ['this-is-page-one', 'this-is-page-two']
  end

end
