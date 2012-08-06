require 'spec_helper'

describe Comment do

  before(:each) do
    @page = Page.create( title: 'A Commentable Page', permalink: 'commentable' )
  end

  it "should not be shorten than 20 chars" do
    @comment = @page.comments.create( comment: "First Comment " )
    @comment.errors.first.should include(:comment,'is too short (minimum is 20 characters)')
  end

  it "is embedded in Page" do
    @page.comments.count.should == 0
    @comment = @page.comments.create( comment: "First Comment "*10 )
    @page.comments.count.should == 1
    @page.comments.first.comment.should == "First Comment "*10
  end
  
end