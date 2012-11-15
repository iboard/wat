# -*- encoding : utf-8 -*-"
#
# @author Andi Altendorfer <andreas@altendorfer.at>
# @since 26.08.12
#
require "rspec"

describe UsersController do

  before(:all) do
    $NO_TIMELINE_FOR_SPECS = false
  end
  after(:all) do
    $NO_TIMELINE_FOR_SPECS = true
  end

  before(:each) do
    @user = test_user "Mr. Nice", "secret"
    visit switch_language_path(:en)
    sign_in_user name: "Mr. Nice", password: "secret"
    visit timelines_path
    page.should have_content "Personal Timeline"
  end

  it "should allwow to enable personal timeline" do
    page.should have_css "#timeline_name"
    page.should have_css "#timeline_enabled"
    page.should have_css "#timeline_public"
  end

  it "should store settings" do
    fill_in "timeline_name", with: "Frank says ..."
    check "timeline_enabled"
    uncheck "timeline_public"
    click_button "Update & Refresh"

    @user.timeline.name.should == "Frank says ..."
    @user.timeline.enabled.should be_true
    @user.timeline.public.should_not be_true
  end
end