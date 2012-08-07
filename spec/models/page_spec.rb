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
    
    Page.with_banner.map(&:_id).sort.should == ['this-is-page-one', 'this-is-page-two' ]
  end

  it "generates a random sorting_id before save" do
    page = Page.create(permalink: 'sortme', title: 'Sort Me', body: 'Second Body')
    page.sorting_id.length.should == 42
  end

  it "supports position and sorting (within a section)" do
    Page.delete_all
    page2 = Page.create(permalink: 'two', title: 'Page Two', position: 1, body: 'Second Body')
    page3 = Page.create(permalink: 'three', title: 'Page tree', position: 2, body: 'Third Body')
    page1 = Page.create(permalink: 'one', title: 'Page One', position: 0, body: 'First Body')
    Page.all.map(&:permalink).should == %w(one two three)
  end

  describe "supports publish_at and expire_at:" do

    before(:each) do
      Page.delete_all
      Page.create(permalink: 'always', title: 'Always online')
      Page.create(permalink: 'published', title: 'Published', publish_at: Time.now-1.day)
      Page.create(permalink: 'will publish', title: 'Will publish', publish_at: Time.now+1.day)
      Page.create(permalink: 'will expire', title: 'Will expire', expire_at: Time.now+1.day)
      Page.create(permalink: 'expired', title: 'Expired', expire_at: Time.now-1.day)
      Page.create(permalink: 'in range', title: 'In range', publish_at: Time.now-1.day, expire_at: Time.now+1.day)
      Page.create(permalink: 'to early', title: 'To early', publish_at: Time.now+1.day, expire_at: Time.now+2.days)
      Page.create(permalink: 'to late', title: 'To late', publish_at: Time.now-2.days, expire_at: Time.now-1.day)
    end

    it "unscoped - lists all pages in unscoped" do
      Page.unscoped.map(&:permalink).count.should    == 8
    end

    it "published - lists only pages with no publish_at or publish_at already passed" do
      Page.published.map(&:permalink).sort.should    == ['always','expired','in range','published','to late', 'will expire']
    end

    it "will publish - lists pages which has a published_at set and will be published in future" do
      Page.will_publish.map(&:permalink).sort.should == ['to early', 'will publish']
    end

    it "will expire - lists pages which has an expire_at set and will expire in future" do
      Page.will_expire.map(&:permalink).sort.should == ['in range', 'to early', 'will expire']
    end

    it "expired - lists expired pages" do
      Page.expired.map(&:permalink).sort.should == ['expired', 'to late']
    end

    it "online - lists pages with boundaries nil or in range" do
      Page.online.map(&:permalink).sort.should == ['always','in range','published','will expire']
    end

  end

end
