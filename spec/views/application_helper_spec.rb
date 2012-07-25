require File::expand_path('../../spec_helper', __FILE__)
require 'capybara/rspec'
require 'spec_helper'

describe LayoutHelper do

  include LayoutHelper

  it "humanized_filesize" do
    humanized_filesize( 1 ).should == "1 Byte"
    humanized_filesize( 2.kilobytes ).should == "2 KB"
    humanized_filesize( 3.megabytes ).should == "3 MB"
    humanized_filesize( 4.gigabytes ).should == "4 GB"
  end
  
end