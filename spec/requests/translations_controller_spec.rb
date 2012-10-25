# -*- encoding : utf-8 -*-"
require "rspec"

describe TranslationsController do

  before(:each) do
    user=test_user "Translator", "babelfish", ["Locale Admin"]
    sign_in_user name: "Translator", password: "babelfish"
  end

  it "should list translations keys" do
    click_link "Edit this translations"
    page.should have_content "edit_profile en Edit profile de Benutzerkonto bearbeiten"
  end
end