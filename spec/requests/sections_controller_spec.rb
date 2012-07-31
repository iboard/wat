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

  describe "As an admin" do
    before(:each) do
      Page.delete_all
      Section.delete_all
      @admin = test_user "admin", "secret", ['Admin','Author']
      sign_in_user name: 'admin', password: 'secret'
    end

    it "lists sections" do
      Section.create( permalink: "S1", title: "Section One", body: lorem())
      visit sections_path
      page.should have_content "Section One"
      page.should have_content "Lorem ipsum"
    end

    it "allows to create a new section" do
      visit sections_path
      click_link "Create Section"
      fill_in "section_permalink", with: "section one"
      fill_in "section_title", with: "First Section"
      fill_in "section_body", with: lorem()
      click_button "Create Section"
      page.should have_content "Section successfully created"
      page.should have_content "First Section"
    end

    it "allows to edit a section" do
      Section.create( permalink: "S1", title: "Section One", body: lorem())
      visit sections_path
      page.all('.span12 a', text: 'Edit').first.click()
      page.should have_content "Edit Section"
      fill_in "section_body", with: "There is a big difference between kneeling down and bending over"
      click_button "Update Section"
      page.should have_content "Section successfully updated"
      page.should have_content "kneeling down"
    end

    it "allows to delete a section" do
      Section.create( permalink: "S1", title: "Section One", body: lorem())
      _page = Section.first.pages.create(permalink:'p1', title: 'Page ONE', body: 'I am here')
      visit sections_path
      page.all('.span12 a', text: 'Delete').first.click()
      page.should have_content "Section successfully deleted"
      page.should have_no_content "Section One"
      visit page_path(_page)
      page.should have_content "Page ONE"
      page.should have_content "I am here"
    end

    it "prevents non-admins from edit,create,new,update,and destroy" do
      section = Section.create( permalink: "S1", title: "Section One", body: lorem())
      visit signout_path
      visit edit_section_path(section)
      page.should have_content "Access denied"
      visit new_section_path
      page.should have_content "Access denied"
      visit sections_path
      page.should have_content "Access denied"
    end


  end

end
