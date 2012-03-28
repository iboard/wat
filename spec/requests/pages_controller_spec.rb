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
    page.should have_content "Lorem ipsum dolor"
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

  describe "Let an admin" do

    before(:each) do
      _usr = User.first
      _usr.facilities.find_or_create_by( name: 'Admin', access: 'rwx' )
      _usr.email_confirmed_at = Time.now
      _usr.save!
      visit switch_language_path(:en)
      visit page_path(@page)
    end

    it "edit the page" do
      page.click_link "Edit page"
      fill_in "page_body", with: "This is a modified page."
      
      click_button "Save page"
      page.should have_content @page.title
      page.should have_content "This is a modified page"
    end

    it "see a new page button" do
      page.should have_link "Create page"
    end

    it "create a new page" do
      page.should have_link "Create page"
      click_link "Create page"
      fill_in "page_permalink", with: "A new page for WAT"
      fill_in "page_title", with: "A new page for WAT"
      fill_in "page_body", with: lorem()
      click_button "Save page"
      page.should have_content "Page successfully created"
      page.should have_content "A new page for WAT"
      page.should have_content "Lorem ipsum"
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

    it "see the destroy-button" do
      page.should have_link "Delete page"
    end

    it "delete a page" do
      page.should have_content "Lorem ipsum"
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
      Page.create permalink: "@feature1", title: '@feature1', body: "Ruby Is Hero"
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
    end

    it "finds pages using the search-form with JS", js: true do
      _usr = User.first.facilities.find_or_create_by name: 'Admin', access: 'rwx'
      _usr.save!
      switch_language_path(:en)
      sign_in_user name: "Testuser", password: "notsecret"
      Page.create permalink: "@feature1", title: '@feature1', body: "Ruby Is Hero"
      Page.create permalink: "Find Me", title: "Find Me", body: "You catched me!"
      visit pages_path
      page.should have_content "Ruby Is Hero"
      fill_in 'search_search_text', with: "find"
      page.should_not have_button "Search"
      page.should have_content "You catched me!"
      page.should_not have_content "Ruby Is Hero"
    end
  end
end
