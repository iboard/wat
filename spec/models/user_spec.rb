require 'spec_helper'

describe User do

  it "uses name as a key" do
    user = User.create!(name: 'Andi Altendorfer', email: 'andreas@altendorfer.at')
    assert User.find('andi-altendorfer') == user
  end

  it "doesn't allow two users having the same name" do
    user1 = User.create!(name: 'Andi Altendorfer', email: 'andreas@altendorfer.at')
    user2 = User.new(  name: 'Andi Altendorfer', email: 'andi@altendorfer.at')
    assert !user2.valid?(), 'User with same name should not be created'
  end

  it "removes identities when destroyed" do
    user = User.create!(name: "Test With Identities", email: 'identity@iboard.cc')
    identity = Identity.create!(provider: 'identity', uid:'test123', name: 'Test With Identities', password:"12345", password_confirmation: "12345")
    user.authentications = [ identity ]
    user.save!
    assert user.authentications.count == 1
    assert Identity.count == 1, "there should be one identity"
    user.destroy
    assert Identity.count == 0, "Identity should have been deleted"
  end

  describe "(standard user)" do
    before :each do
      User.delete_all
      @user = test_user "The Pirate", "ahoid"
    end

    it "sends a forgot password link" do
      user = User.where(email: 'the.pirate@example.com').first
      user.reset_password
      last_email.to.should include('the.pirate@example.com')
      last_email.parts.first.body.should  match /requeset to reset your password/
    end
  end

end
