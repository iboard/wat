require 'spec_helper'
require 'capybara/rspec'


describe HomeController do

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

end

describe ApplicationController do

  describe "Application Layout" do

    before(:each) do
      visit root_path
    end

    it "has a link to 'Home'" do
      page.should have_link "Home"
    end

    it "has a link to 'Log in'" do
      page.should have_link "Log in"
    end
    
  end
end
