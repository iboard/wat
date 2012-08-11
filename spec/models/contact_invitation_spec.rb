require 'spec_helper'

describe ContactInvitation do

  before :each do
    test_user "Frank Zappa", "secret word for today"
    @user = User.find('frank-zappa')
  end
  
  it "stores a sender and a recipient" do
    invitation = ContactInvitation.create( sender:@user, recipient_email: 'egon.schiele@example.com' )
    invitation.should_not be_nil
    invitation.sender.should == @user
    invitation.recipient_email.should == 'egon.schiele@example.com'
  end

  it "generates a token at create" do
    invitation = ContactInvitation.create( sender: @user, recipient_email: 'egon.schiele@example.com' )
    invitation.token.should =~ /\A[0-9a-fA-F]{20}\Z/
  end

  it "generates a mail to the recipient" do
    invitation = ContactInvitation.create( sender: @user, recipient_email: 'egon.schiele@example.com', message: "Lorem Ipsum my friend" )
    last_email.to.should include('egon.schiele@example.com')
    last_email.parts.first.body.should  match /#{@user.name} invites you/
    last_email.parts.first.body.should  match /#{invitation.token}/
    last_email.parts.first.body.should  match "Lorem Ipsum my friend"
  end

  it "connects two users with user.accept_contact_invitation" do
    test_user "My Friend", "secret"
    friend = User.find('my-friend')
    invitation = ContactInvitation.create( sender: @user, recipient_email: 'my.friend@example.com')
    friend.accept_contact_invitation(invitation)
    @user.reload
    friend.reload
    @user.contacts.first.should_not be_nil
    @user.contacts.first.name.should == "My Friend"
    friend.reverse_contacts.first.should == @user
  end



end
