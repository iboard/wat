require 'spec_helper'

describe "Internationalization" do
  it "switches language" do
    visit root_path
    if Settings.multilanguage == true
      page.should have_content "Sign in"
      click_link "Deutsch"
      page.should have_content "Anmelden"
      click_link "English"
      page.should have_content "Sign in"
    else
      visit switch_language_path(:de)
      page.should have_content I18n.t(:cannot_change_language)
    end
  end
end

