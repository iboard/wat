require 'spec_helper'

describe "Internationalization" do
  it "switches language" do
    visit root_path
    page.should have_content "Sign in"
    click_link "Deutsch"
    page.should have_content "Anmelden"
    click_link "English"
    page.should have_content "Sign in"
  end
end

