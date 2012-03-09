require 'spec_helper'

describe Facility do

  it "defines class Facility for User" do
    user = User.create(name: 'Testuser', email: 'test@iboard.cc')
    user.facilities.create(name: 'Admin', access: 'rwx')
    user.save!
    user.reload

    assert user.can_read?('Admin'), 'can_read? should be true'
    assert user.can_write?('Admin'), 'can_write? should be true'
    assert user.can_execute?('Admin'), 'can_execute? should be true'

    assert !user.can_execute?('God'), 'Nobody should be execute as god!'
  end

end