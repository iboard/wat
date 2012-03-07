require 'spec_helper'

describe Page do

  it "uses title as key" do
    page = Page.new(:title => 'This is Page One')
    page.save
    _page = Page.find("this-is-page-one")
    assert _page.eql?(page), "Page should be addressed by key"
  end

end
