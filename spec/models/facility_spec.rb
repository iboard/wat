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

  it "checks one facility at a time" do
    user = User.find_or_create_by(name: 'Testuser', email: 'test@iboard.cc')
    user.email_confirmed_at = Time.now
    user.facilities.create(name: 'one', access: 'rwx')
    user.can_read?('one').should == true
    user.can_write?('one').should == true
    user.can_execute?('one').should == true
    user.can_read?('two').should == false
    user.can_write?('two').should == false
    user.can_execute?('two').should == false
  end

  it "checks more facilities at once" do
    user = User.find_or_create_by(name: 'Testuser', email: 'test@iboard.cc')
    user.email_confirmed_at = Time.now
    user.facilities.create(name: 'F1', access: 'rwx')
    user.facilities.create(name: 'F2', access: 'rwx')
    user.can_read?('F1','F2').should == true
    user.can_write?('F1','F2').should == true
    user.can_execute?('F1','F2').should == true
    user.can_read?('x1','x2').should == false
    user.can_write?('x1','x2').should == false
    user.can_execute?('x1','x2').should == false
  end

  describe "firendship" do
    before(:each) do
      User.delete_all
      @me = test_user 'Myself', 'secret', ['User']
      @friends = (1..5).to_a.map { |f| test_user "Friend #{f}", 'secret', ['User'] }
      User.count.should == 6
    end

    it "can store my contacts" do
      _facility = @me.facilities.create name: 'My friends', access: 'rwx'
      _facility.add_consumers User.where( :name => /Friend [135]{1}/ )
      _facility.consumers.count.should == 3
      @me.contacts.count.should == 3
      [1,3,5].each do |f|
        @me.contacts.should include(User.where(name: "Friend #{f}").first)
      end
    end

    it "can find me in reverse contacts" do
      _facility = @me.facilities.create name: 'My friends', access: 'rwx'
      _facility.add_consumers User.where( :name => /Friend [135]{1}/ )
      @me.save!
      
      # prevent from being trivial!
      # make sure @me is not the only contact in revers_contacts
      f2 = User.find('friend-3')
      fa2=f2.facilities.create( name: 'My friends', access: 'rwx' )
      fa2.add_consumers User.where( :name => /Friend [15]{1}/ )
      f2.save!

      _friend = User.find("friend-1")
      _friend.reverse_contacts.should include(@me)
      _friend.reverse_contacts.should include(f2)
      _f5 = User.find("friend-5")
      _f5.reverse_contacts.should include(f2)
    end
  end

end