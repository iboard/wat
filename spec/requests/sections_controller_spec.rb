require File::expand_path('../../spec_helper', __FILE__)
require 'capybara/rspec'
require 'application_helper'

include ApplicationHelper

describe PagesController do

  before(:each) do
    Section.delete_all
    @section = Section.create!(permalink: "section one", title: 'Section ONE', body: lorem())
    @section.save!
    @section.pages.create(:permalink => 'page 1', :title => 'Page One', body: 'Page one body')
    @section.pages.create(:permalink => 'page 2', :title => 'Page Two', body: 'Page two body')
    @section.save!
    User.delete_all
    Identity.delete_all
    visit switch_language_path(:en)
    test_user 'Testuser', 'notsecret'
    sign_in_user name: 'Testuser', password: 'notsecret'
  end  

  it "shows up in the main menu" do
    visit root_path
    page.should have_link "Page One"
    page.should have_link "Page Two"
  end


end
