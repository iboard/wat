# -*- encoding : utf-8 -*-"
require 'spec_helper'

describe Identity do

  after(:each) do
    Settings.merge!(public_sign_up: 'enabled')
  end

  it "should validate invitation token" do
    Settings.merge!( public_sign_up: 'disabled')
    identity = Identity.create(name: "No Invitation", provider: 'identity',
                               password: '12345', password_confirmation: '12345')
    identity.should_not be_valid
    identity.errors[:invitation_token].should include("You have to enter an invitation-token")
  end

end