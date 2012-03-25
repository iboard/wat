require File::expand_path('../../spec_helper', __FILE__)
require 'capybara/rspec'

describe UserPresenter do
  it "says if no username given" do
    presenter = UserPresenter.new(User.new, view)
    presenter.name.should include(I18n.t(:no_name_given))
  end
end