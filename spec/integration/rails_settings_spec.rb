require 'spec_helper'

describe "RailsSetting" do
  it "loads settings from config/settings/*yml" do
    assert Settings.smtp_server == "mail.example.com" , "Settings should be loaded from congig/settigs/"
  end
end

