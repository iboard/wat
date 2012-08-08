require File::expand_path('../../spec_helper', __FILE__)
require 'capybara/rspec'

describe HomeController do

  describe "GET 'index'" do
    it "returns http success" do
      get root_path
      response.status.should be(200)      
    end
  end

end

describe ApplicationController do

  describe "Application Layout" do

    before(:all) do
      Page.delete_all
      @page = Page.create!(permalink: "First Page", title: 'First Page', body: 'Lorem ipsum dolores')
    end
        
    before(:each) do
      visit root_path
    end

    it "always has a link to 'Home'" do
      page.should have_link Settings.application_brand
    end

    it "renders a carousel including all pages with banners" do
      p1 = Page.create( permalink: 'page one with banner', title: 'First Banner', body: 'Banner ONE', banner_title: 'Title Banner One')
      b1 = p1.create_banner
      b1.update_attributes(banner: File.new(PICTURE_FILE_FIXTURE))
      p1.save!
      p2 = Page.create( permalink: 'page two with banner', title: 'Second Banner', body: 'Banner TWO', banner_title: 'Title Banner Two')
      b2 = p2.create_banner
      b2.update_attributes(banner: File.new(PICTURE_FILE_FIXTURE))
      p2.save!
      visit root_path
      page.should have_content("Title Banner One")
      page.should have_content("Title Banner Two")
    end

    describe "When not logged in" do

      it "has a link to 'Sign in'" do
        page.should have_link "Sign in"
      end
  
      it "shows the hero-page" do
        Page.create permalink: 'hero', title: 'hero', body: "This is the hero\n==========\n\nlorem ipsum dolores"
        visit root_path
        page.should have_content "This is the hero"
      end

      it "no longer shows a message to create the hero-page if not exists" do
        Page.delete_all
        visit root_path
        page.should_not have_content "Please create a page with permalink 'hero' which will be displayed here."
      end

      it "shows pages prefixed by @" do
        Page.create permalink: '@header1', title: '@header1', body: "This is for the homepage"
        visit root_path
        page.should have_content "This is for the homepage"
      end

      it "doesn't show the featured-label" do
        Page.create permalink: '@header2', title: '@header2', body: "This is for the homepage"
        visit root_path
        page.should_not have_content "FEATURED"
      end

      it "shows a sign-up item under sign in menu" do
        visit root_path
        click_link "Sign in"
        click_link "Register new account"
        page.should have_content "New account"
        page.should have_content "Before you create an account"
      end

      it "shows pages with defined preview-length on the homepage" do
        Page.create permalink: "@10", title: "10 Characters preview", body: "lorem ipsum dolores", preview_length: 10
        visit root_path
        page.should have_content "lorem ..."
        page.should have_link I18n.translate(:read_more)
        page.should_not have_content "dolores"
      end

      it "shows default preview length if no value is given" do
        Page.create permalink: "@full length", title: "Longer preview", body: lorem_text
        visit root_path
        page.should have_content "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in ..."
      end
    end

    describe "When logged in" do

      before(:each) do
        User.delete_all
        Identity.delete_all
        sign_up_user name: 'Testuser', password: 'notsecret', email: 'test@iboard.cc'
      end

    end
    
  end
end
