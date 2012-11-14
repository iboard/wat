# -*- encoding : utf-8 -*-"
require "rspec"

describe "Translations with redis" do

  it "should reads from redis" do
    I18n.backend.store_translations(:en, {"test_redis" => "Test redis backend"}, :escape => false)
    I18n.t(:test_redis).should == "Test redis backend"
    I18n.backend.store_translations(:en, {"test_redis" => nil}, :escape => false)
    I18n.t(:test_redis).should == "translation missing: en.test_redis"
  end

end