require File::expand_path('../../spec_helper', __FILE__)
require 'capybara/rspec'

describe HomeController do
  describe SessionsController do
  
    describe "Log in page" do
  
      before(:each) do
        visit signin_path
      end
  
      it "list all omniauth providers" do
        Secrets::defined_providers.each do |provider|
          page.should have_link provider.to_s.humanize
        end
      end

      it "provides openid link" do
        if Secrets::secret['openid']
          page.should have_link "OpenID"
        end
      end

      it "has a form to login with identiy" do
        page.should have_selector '#auth_key'
        page.should have_selector '#password'
      end
      
    end
  end
end