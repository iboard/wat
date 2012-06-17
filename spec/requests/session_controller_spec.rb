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

      it "redirects to the addressed page after successful login" do
        Page.delete_all
        @page = Page.create!(permalink: "First Page", title: 'First Page', body: "Lorem Ipsum")
        User.delete_all
        Identity.delete_all
        visit switch_language_path(:en)
        test_user 'Testuser', 'notsecret', 'Admin'
        visit edit_page_path(@page)
        page.should have_content "Sign in"
        fill_in 'Name', with: 'Testuser'
        fill_in 'Password', with: 'notsecret'
        click_button 'Sign in'
        page.should have_content "Edit page"
        page.should have_content "The permalink can't be changed once the page is created."
      end
      
    end
  end
end