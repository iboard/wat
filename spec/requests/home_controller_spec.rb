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
      @page = Page.create!(title: "First Page", body: 'Lorem ipsum dolores')
    end
        
    before(:each) do
      visit root_path
    end

    it "always has a link to 'Home'" do
      page.should have_link "Home"
    end

    describe "When not logged in" do

      it "has a link to 'Sign in'" do
        page.should have_link "Sign in"
      end
  
      it "shows the hero-page" do
        Page.create title: 'hero', body: "This is the hero\n==========\n\nlorem ipsum dolores"
        visit root_path
        page.should have_content "This is the hero"
      end

      it "shows a message to create the hero-page if not exists" do
        Page.delete_all
        visit root_path
        page.should have_content "Please create a page titled 'hero' which will be displayed here"
      end

      it "shows pages prefixed by @" do
        Page.create title: '@header1', body: "This is for the homepage"
        visit root_path
        page.should have_content "This is for the homepage"
      end

      it "doesn't show the featured-label" do
        Page.create title: '@header2', body: "This is for the homepage"
        visit root_path
        page.should_not have_content "FEATURED"
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
