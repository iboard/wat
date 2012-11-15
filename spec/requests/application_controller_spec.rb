require 'spec_helper'

describe ApplicationController do

  before(:each) do
    Page.delete_all
    Page.create permalink: 'online-page', title: 'header for online', body: "This is for the online-homepage", is_online: true
    Page.create permalink: 'not-online-page', title: 'header for not online', body: "This is for the not-online-homepage", is_online: false
    test_user 'Testuser', 'notsecret'
    visit root_path
  end

  it "can search for online pages without JS" do
    page.should have_css "#search_search_text"
    fill_in 'search_search_text', with: "online"
    click_button "Search"
    page.all('h1', text: "This is for the online-homepage").should_not be_nil
    page.all('h1', text: "This is for the not-online-homepage").should be_empty
  end

  it "can search for online pages with JS", js: true do
    page.should have_css "#token-input-search_search_text"
    page.find(:xpath, "//tester").set "online"
    keypress_script = "var e = $.Event('keyup', { keyCode: #{13} }); $('#token-input-search_search_text').trigger(e);"
    page.driver.browser.execute_script(keypress_script)
    page.all('h1', text: "This is for the online-homepage").should_not be_nil
    page.all('h1', text: "This is for the not-online-homepage").should be_empty
  end

  it "when logged in is possible to search for online pages without JS" do
    sign_in_user name: 'Testuser', password: 'notsecret'
    page.should have_css "#search_search_text"
    fill_in 'search_search_text', with: "online"
    click_button "Search"
    page.all('h1', text: "This is for the online-homepage").should_not be_nil
    page.all('h1', text: "This is for the not-online-homepage").should be_empty
  end

  it "when logged in is possible to search for online pages with JS", js: true do
    visit switch_language_path(:en)
    sign_in_user name: 'Testuser', password: 'notsecret'
    page.should have_css "#token-input-search_search_text"
    page.find(:xpath, "//tester").set "online"
    keypress_script = "var e = $.Event('keyup', { keyCode: #{13} }); $('#token-input-search_search_text').trigger(e);"
    page.driver.browser.execute_script(keypress_script)
    page.all('h1', text: "This is for the online-homepage").should_not be_nil
    page.all('h1', text: "This is for the not-online-homepage").should be_empty
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
