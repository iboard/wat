require File::expand_path('../../spec_helper', __FILE__)
require 'capybara/rspec'
require 'application_helper'

include ApplicationHelper

describe PagesController do

  before(:each) do
    Page.delete_all
    @page = Page.create!(permalink: "First Page", title: 'First Page', body: lorem())
    User.delete_all
    Identity.delete_all
    visit switch_language_path(:en)
    test_user 'Testuser', 'notsecret'
    sign_in_user name: 'Testuser', password: 'notsecret'
  end  

  it "page should show up with title as key" do
    visit page_path(@page)
    page.should have_content "First Page"
  end
    
  it "has an edit-button for admins" do
    _usr = User.first
    visit page_path(@page)
    page.should_not have_link "Edit page"
    
    _usr.facilities.create name: 'Admin', access: 'rwx'
    _usr.save!
    
    visit page_path(@page)
    page.should have_link "Edit page"
  end

  it "allows new/edit/create/update for Authors only" do
    visit signout_path
    visit new_page_path
    page.should have_content I18n.t(:you_need_to_sign_in)
  end

  describe "Let an admin" do

    before(:each) do
      _usr = User.first
      _usr.facilities.find_or_create_by( name: 'Admin', access: 'rwx' )
      _usr.email_confirmed_at = Time.now
      _usr.save!
      visit switch_language_path(:en) if Settings.multilanguage != false
      visit page_path(@page)
    end

    it "edit the page" do
      $NO_TIMELINE_FOR_SPECS = false
      page.click_link "Edit page"
      fill_in "page_body", with: "This is a modified page."
      
      click_button "Save page"
      if Settings.supress_page_title != true
        page.all('article h1', text: @page.title).first.should_not be_nil
      else
        page.all('article h1', text: @page.title).first.should be_nil
      end
      page.should have_content "This is a modified page"
      latest_content_event.text.should == "<span class='timestamp-timeline'>less than a minute ago,</span><span class='timeline-username'>[Testuser](/users/testuser/profile)</span><br/><sapn class='timeline-message'>saved page '[First Page](/pages/first-page)'</span>"
      $NO_TIMELINE_FOR_SPECS = true
    end

    it "see a new page button" do
      page.should have_link "Create page"
    end

    it "create a new page" do
      $NO_TIMELINE_FOR_SPECS = false
      page.should have_link "Create page"
      click_link "Create page"
      fill_in "page_permalink", with: "A new page for WAT"
      fill_in "page_title", with: "A new page for WAT"
      fill_in "page_body", with: lorem()
      click_button "Save page"
      page.should have_content "Page successfully created"
      if Settings.supress_page_title != true
        page.all('h1', text: "A new page for WAT").first.should_not be_nil
      else
        page.all('h1', text: "A new page for WAT").first.should_not be_nil
      end
      latest_content_event.text.should == "<span class='timestamp-timeline'>less than a minute ago,</span><span class='timeline-username'>[Testuser](/users/testuser/profile)</span><br/><sapn class='timeline-message'>created page '[A new page for WAT](/pages/a-new-page-for-wat)'</span>"
      $NO_TIMELINE_FOR_SPECS = true
    end

    it "accepts uploading pictures for banner and links to target url" do
      click_link "Create page"
      fill_in "page_permalink", with: "Page with Banner"
      fill_in "page_title", with: "Page with Banner"
      fill_in "page_body", with: lorem()
      banner_file = File.join(::Rails.root, "fixtures/avatar.jpg") 
      attach_file("page_banner_banner", banner_file)
      fill_in "page_banner_linked_url", with: "http://wwedu.com"
      click_button "Save page"
      page.should have_css '#banner'
      page.all('a', href: "http://wwedu.com").first.should_not be_nil
      page.should have_css '#scroll-to'
    end

    it "sort pages" do
      Page.delete_all
      page2 = Page.create(permalink: 'two', title: 'Page Two', position: 1, body: 'Second Body')
      page3 = Page.create(permalink: 'three', title: 'Page tree', position: 2, body: 'Third Body')
      page1 = Page.create(permalink: 'one', title: 'Page One', position: 0, body: 'First Body')
      visit pages_path
      page.should have_link "Sort Pages"
      click_link "Sort Pages"
      page.should have_css "#ordered_pages"
    end

    it "restricts access to sort for admins only" do
      visit signout_path
      visit sort_pages_path
      page.should have_content "You need to sign in for access to this page"
      page.should_not have_content "Sort pages"
    end

    it "see the destroy-button" do
      page.should have_link "Delete page"
    end

    it "delete a page" do
      # doesn't work on MountainLion => page.should have_content "Lorem ipsum"
      click_link "Delete page"
      page.should have_content "Page successfully deleted"
    end

    it "list available pages" do
      ["Page One", "Page Two", "Page Three"].each do |_title|
        Page.create permalink: _title, title: _title, body: lorem
      end
      visit pages_path
      page.should have_link "Page One"
      page.should have_link "Page Two"
      page.should have_link "Page Three"
    end

    it "delete a page from the page::index" do
      Page.create permalink: "please destroy me", title: "please destroy me", body: "Hello World"
      visit pages_path
      page.should have_link "Delete"
    end

    it "edit a page from the page::index" do
      Page.create permalink: "please edit me", title: "please edit me", body: "Hello World"
      visit pages_path
      page.should have_link "Edit page"
    end

    it "create a new page from page::index" do
      visit pages_path
      page.should have_link "Create page"
    end

    it "should not accept empty permalinks" do
      visit new_page_path
      fill_in "page_permalink", with: ""
      fill_in "page_title", with: "ABC"
      fill_in "page_body", with: lorem
      click_button "Save page"
      page.should have_content "Permalinkcan't be blank"
    end

    it "should not accept empty title" do
      visit new_page_path
      fill_in "page_title", with: ""
      fill_in "page_body", with: lorem
      click_button "Save page"
      page.should have_content "Titlecan't be blank"
    end

    it "labels hero-unit" do
      Page.create permalink: "hero", title: 'hero', body: "Ruby Is Hero"
      visit pages_path
      page.should have_content "HERO-UNIT"
    end

    it "labels featured-articles" do
      Page.create permalink: "@feature1", title: '@feature1', body: "Ruby Is Hero", featured: true
      visit pages_path
      page.should have_content "FEATURED"
    end

    it "finds pages using the search-form without JS" do
      Page.create permalink: "@feature1", title: '@feature1', body: "Ruby Is Hero"
      Page.create permalink: "Find Me", title: "Find Me", body: "You catched me!"
      visit pages_path
      fill_in 'search_search_text', with: "find"
      click_button "Search"
      page.should have_content "You catched me!"
      page.should_not have_content "Ruby Is Hero"
    end

    it "finds pages using the search-form with JS", js: true do
      _usr = User.first.facilities.find_or_create_by name: 'Admin', access: 'rwx'
      _usr.save!
      switch_language_path(:en)
      sign_in_user name: "Testuser", password: "notsecret"
      Page.create permalink: "@feature1", title: '@feature1', body: "Ruby Is Hero"
      Page.create permalink: "Find Me", title: "Find Me", body: "You catched me!"
      visit pages_path
      page.all('h1', text: "Ruby Is Hero").should_not be_nil
      page.find(:xpath, "//tester").set "find"
      page.should_not have_button "Search"
      keypress_script = "var e = $.Event('keyup', { keyCode: #{13} }); $('#token-input-search_search_text').trigger(e);"
      page.driver.browser.execute_script(keypress_script)
      page.all('h1', text: "You catched me!").should_not be_nil
      page.all('h1', text: "Ruby Is Hero").should be_empty
    end

    it "let change featured on/off" do
      visit edit_page_path(@page)
      check "Show on start-page."
      click_button "Save page"
      Page.featured.where(_id: @page._id).first.should_not be_nil
      visit edit_page_path(@page)
      uncheck "Show on start-page."
      click_button "Save page"
      Page.featured.where(id: @page._id).first.should be_nil
    end

    describe "Translations" do

      before(:each) do
        visit switch_language_path(:en)
        click_link "Create page"
        fill_in "page_permalink", with: "what we eat"
        fill_in "page_title", with: "Fish'n'Chips"
        fill_in "page_body", with: "ugly!"
        click_button "Save page"
      end
      
      it "displays translation-links after create" do
        page.should have_link "Translate for 'de'"
        page.should have_link "read"
      end

      it "lets read the available translation" do
        visit page_path(Page.find('what-we-eat'))
        click_link "read"
        page.should have_content "Fish'n'Chips"
      end
  
      it "lets the author edit the missing translation" do
        visit page_path(Page.find('what-we-eat'))
        click_link "Translate for 'de'"
        fill_in "page_title", with: "A Gulasch und a Bier"
        fill_in "page_body", with: "Guaaaat!"
        click_button "Seite speichern"
        page.should have_content "Guaaaat!"
        switch_language_path('en')
      end     
    end

    describe "manage versions" do

      it "creates versions on save but hides versions from non-admins" do
        _page = Page.create(permalink: 'testversions', title: 'Initial Version', body: 'Initial Body')
        visit edit_page_path(_page)
        fill_in "page_title", with: "This is the new version"
        fill_in "page_body", with: "A modified Body"
        click_button "Save page"
        _page.reload
        visit page_path(_page)
        page.should have_content "Available versions of this document"
        page.should have_link "#{Time.now.strftime('%Y-%m-%d %H:%M')}less than a minute agoThis is the new version"
        page.should have_link "#{Time.now.strftime('%Y-%m-%d %H:%M')}less than a minute agoInitial Version"

        visit signout_path
        visit page_path(_page)
        page.should_not have_content "Available versions of this document"
        page.should_not have_link "#{Time.now.strftime('%Y-%m-%d %H:%M')}less than a minute agoThis is the new version"
        page.should_not have_link "#{Time.now.strftime('%Y-%m-%d %H:%M')}less than a minute agoInitial Version"

      end

      describe "can restore older version" do

        before(:each) do
          @page = Page.create( permalink: 'test page one', title: 'Test Page 1', body: 'initial body', banner_title: 'first banner', banner_text: 'first banner text')
          @page.update_attributes( title: 'Test Page 2')
          @page.save!
          visit page_path(@page)
        end

        it "shows lates version by default" do
          page.all("h1",:text =>"Test Page 2").first.should_not be_nil
        end

        it "user has to show version before restoring" do
          click_link "Show version #1"
          page.all("h1",:text =>"Test Page 1").first.should_not be_nil
        end

        it "can restore currently displayed version" do
          visit restore_version_page_path(@page,1)
          page.all("h1",:text =>"Test Page 1").first.should_not be_nil
        
          # Now this version should be the default
          visit page_path(@page)
          page.all("h1",:text =>"Test Page 1").first.should_not be_nil
        end

      end

    end
  end

  describe "Supports pages in sections" do
    before(:each) do
      Page.delete_all
      Section.delete_all
      
      @section = Section.create permalink: 'sectionone', title: "Section One", body: "Nothing"
      
      @page  = Page.create!(permalink: "First Page", title: 'First Page', body: lorem())
      @page2 = Page.create!(permalink: "Second Page", title: 'Second Page', body: lorem())
      @page.section = @section
      @page2.section= @section
      @page.save!
      @page2.save

      _usr = User.first
      _usr.facilities.find_or_create_by( name: 'Admin', access: 'rwx' )
      _usr.email_confirmed_at = Time.now
      _usr.save!

      sign_in_user name: 'Testuser', password: 'notsecret'
    end

    it "lists the section of a page in index" do
      visit pages_path
      page.find('.label.section-label').text.should == 'Section One'
    end

    it "allows to assign pages to sections" do
      visit page_path(@page)
      click_link "Edit page"
      select "-- no section --", from: "page_section_id"
      click_button "Save page"
      page.should_not have_css('.section-label')
      click_link "Edit page"
      select "Section One", from: "page_section_id"
      click_button "Save page"
      page.find('.section-label').text.should == 'Section One'
    end

    it "shows the secion menu when viewing a page" do
      visit page_path(@page)
      page.should have_link "Second Page"
    end
  end

  describe "Timed limitation for non-admins" do
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
      visit pages_path
    end

    it "doesn't show expired nor published pages for non-admins" do
      page.should have_content "Always online"
      page.should have_content "Published"
      page.should have_content "Will expire"
      page.should have_content "In range"

      page.should_not have_content "Expired"
      page.should_not have_content "Will publish"
      page.should_not have_content "To late"
      page.should_not have_content "To early"
    end
  end
end
