require 'spec_helper'

describe Facility do

  it "defines class Facility for User" do
    user = test_user 'Testuser', 'secret', ['Admin']
    assert user.can_read?('Admin'), 'can_read? should be true'
    assert user.can_write?('Admin'), 'can_write? should be true'
    assert user.can_execute?('Admin'), 'can_execute? should be true'

    assert !user.can_execute?('God'), 'Nobody should be execute as god!'
  end

  it "must have a name" do
    user = User.find_or_create_by(name: 'Testuser', email: 'test@iboard.cc')
    user.facilities.create(name: '', access: 'rwx')
    assert !user.valid?, 'User should not save with invalid facility'
  end

end