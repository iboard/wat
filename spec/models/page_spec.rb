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

    it "offline - lists pages off boundaries" do
      Page.offline.map(&:permalink).sort.should == ["expired", "to early", "to late", "will publish"]
    end

  describe "supports versioning" do
    before(:each) do
      Page.delete_all
    end

    it "stores two versions and each can be fetched individually" do
      page = Page.create permalink: 'verions', title: 'I have versions', body: "This is Version One"
      page.title = "I have two versions"
      page.save!
      page.title.should == "I have two versions"
      page.version.should == 2
      v1 = Version.new(page,1)
      v2 = Version.new(page,2)
      v1.title.should == "I have versions"
      v2.title.should == "I have two versions"
    end

    it "drops old versions" do
      _page = Page.create permalink: 'verions', title: 'Version 1', body: "This is Version 1"
      11.times do |n|
        _page.title = "Version #{n+2}"
        _page.body  = "This is Version #{n+2}"
        _page.save
      end
      
      _page.version.should == 12
      _page.title.should == 'Version 12'
      
      [9,8,7,6,5,4,3,2,1,0].each do |n|
        _version = Version.new(_page,11-n)
        [_version.title, _version.body].should == ["Version #{11-n}", "This is Version #{11-n}"]
      end

      expect { Version.new(_page,13) }.should raise_error(Versionizer::VersionError)
      expect { Version.new(_page,1) }.should raise_error(Versionizer::VersionError)
    end

    describe "wraps an object in class Version" do 

      before(:each) do
        @page = Page.create permalink: 'verions', title: 'I have versions', body: "This is Version One"
        @page.update_attributes title: 'More Versions', body: "This is the second Version" 
      end

      it "lists available versions" do
        @page.available_versions.should == [1,2]
      end
      
      it "raises an error if initialized with unavailable version" do
        expect { Version.new(@page,4) }.should raise_error(Versionizer::VersionError)
      end
      
      it "delegates request of fields to the specified version" do
        old_page     = Version.new(@page,1)
        current_page = Version.new(@page,2)

        current_page.title.should == 'More Versions'
        old_page.title.should == 'I have versions'
      end

      describe "and handles localized and not localized fields correct" do
        before(:each) do
          Page.delete_all
          @page = Page.create permalink: 'versions', title: 'Initial Title :en', body: '1st body',
            banner: { linked_url: 'urlONE', banner: File.new(PICTURE_FILE_FIXTURE) }
          @page.version.should == 1
          @page.new_record?.should == false

          @page.update_attributes title: "Second Title :en", body: '2nd body', banner: { linked_url: 'urlTWO'}
          @page.version.should == 2
        end

        it "stores versions of primary locale correct" do
          _page = Page.first
          _page.version.should == 2
          _page.title.should == 'Second Title :en'
          _page.body.should  == '2nd body'
          _page.banner.linked_url.should == 'urlTWO'

          _page.update_attributes title: "Third Title :en", body: '3rd body', banner: { linked_url: 'urlTHREE'}
          _page.version.should == 3
        end

        it "can restore previous version " do
          v1 = Version.new(@page,1)
          v1.version.version.should == 1
          v1.title.should == 'Initial Title :en'
          v1.body.should  == '1st body'
          v1.banner.linked_url.should == 'urlONE'

          v1.restore.should == true
          
          @page.version.should == 3
          @page.title.should == 'Initial Title :en'
          @page.body.should  == '1st body'
          @page.banner.linked_url.should == 'urlONE'
        end
      end
      
    end
  end

  end

end
