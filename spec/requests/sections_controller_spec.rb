require File::expand_path('../../spec_helper', __FILE__)
require 'capybara/rspec'
require 'application_helper'

include ApplicationHelper

describe SectionsController do

  before(:each) do
    Section.delete_all
    @section = Section.create!(permalink: "section one", title: 'Section ONE', body: lorem())
    @section.save!
    @page1 = @section.pages.create(:permalink => 'page 1', :title => 'Page One', body: 'Page one body')
    @page2 = @section.pages.create(:permalink => 'page 2', :title => 'Page Two', body: 'Page two body')
    @page1.save!
    @page2.save!
    @section.save!
    @section.reload
    User.delete_all
    Identity.delete_all
    visit switch_language_path(:en)
    test_user 'Testuser', 'notsecret'
    sign_in_user name: 'Testuser', password: 'notsecret'
  end  

  it "links to sections in root-path" do
    visit root_path
    page.should have_link "Section ONE"
  end
  
  it "shows a submenu if more than one page on the section-root-path" do
    visit page_path(@page1)
    page.should have_content "Page one body"
    page.should have_css ".subnav"
    page.should have_css( "#link_to_#{@page2._id}" )
  end
  
  it "section with only one page doesn't show subnav" do
    Section.delete_all
    _section = Section.create!(permalink: "section two", title: 'Section TWO', body: lorem())
    _section.pages.create(:permalink => 'page 1.1', :title => 'SubPage One', body: 'Page one body')
    _section.save!
    _section.reload
    visit section_path(_section)
    page.should_not have_css ".subnav"
  end

end
