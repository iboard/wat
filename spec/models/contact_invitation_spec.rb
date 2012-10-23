require 'spec_helper'

describe ContactInvitation do

  before :each do
    @user = test_user "Frank Zappa", "secret word for today"
    # @user = User.find('frank-zappa')
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

  it "connects two users with user.accept_contact_invitation and creates a UserEvent to sender's timeline" do
    $NO_TIMELINE_FOR_SPECS = false
    @user2 = test_user "Frank Zappa2", "2ndsecret word for today"
    test_user "My Friend", "secret"
    friend = User.find('my-friend')
    invitation = ContactInvitation.create( sender: @user2, recipient_email: 'my.friend@example.com')
    friend.accept_contact_invitation(invitation)
    @user2.reload
    friend.reload
    @user2.contacts.first.should_not be_nil
    @user2.contacts.first.name.should == "My Friend"
    friend.reverse_contacts.first.should == @user2
    # and has created a UserEvent to sender's timeline
    Timeline.find_by(name: @user2.name).timeline_events.last.message.should =~ /has_accepted_invitation/
    $NO_TIMELINE_FOR_SPECS = true
  end



end
