require 'spec_helper'

describe Profile do

  it "is embedded to a user" do
    user = User.create!(name: 'Andi Altendorfer', email: 'andreas@altendorfer.at')
    user.create_profile(phone: "+43 699 12345678")
    user.save
    user.reload
    User.find('andi-altendorfer').profile.phone.should eql "+43 699 12345678"
  end

end
