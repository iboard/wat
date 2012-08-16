require 'spec_helper'

describe ApplicationController do

  before(:each) do
    Page.delete_all
    Page.create( title: 'Page ONE', permalink: 'page one', body: 'Body One')
    Page.create( title: 'Page TWO', permalink: 'page two', body: 'Body Two')
    visit root_path
  end

  it "can search pages with a search-field in the top-menu", js: true do
    visit switch_language_path(:en)
    page.should have_css "#search_search_text"
    fill_in "search_search_text", with: "Body One"
    wait_until { page.has_content?("Page ONE") }
    page.should have_no_content "Page TWO"
  end

  it "can supress the global search by configuration" do
    Settings.supress_global_search=true
    visit root_path
    page.should have_no_css "#search_search_text"
  end

  # pending "TODO: HOWTO mock Settings? => unauthorized access to pages#index is configurable" do
  #
  #   before(:each) do
  #     visit signout_path
  #   end
  #
  #   it "access is enabled by default" do
  #     Settings.supress_gloabl_search=false
  #     visit pages_path
  #     page.should have_no_content "You need to sign in for access to this page"
  #   end
  #
  #   it "can be set in Settings.supress_global_search" do
  #     Settings.supress_gloabl_search=true
  #     visit pages_path
  #     page.should have_content "You need to sign in for access to this page"
  #   end
  # end

  
end