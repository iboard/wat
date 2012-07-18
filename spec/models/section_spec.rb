require 'spec_helper'

describe Section do

  it "uses permalink as key" do
    section = Section.new(:permalink => 'about', :title => "About Sections")
    section.save
    _section = Section.find("about")
    assert _section.eql?(section), "Section should be addressed by key"
  end

  it "has many pages" do
    section = Section.new(:permalink => 'about', :title => "About Sections")
    section.save!
    section.pages.create(:permalink => 'page 1', :title => 'Page One', body: 'Page one body')
    section.pages.create(:permalink => 'page 2', :title => 'Page Two', body: 'Page two body')
    section.save!
    section.reload
    section.pages.count.should == 2
    section.pages.first.title.should == 'Page One'
  end

end
