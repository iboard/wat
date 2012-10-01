# -*- encoding : utf-8 -*-"
#
# @author Andi Altendorfer <andreas@altendorfer.at>
#
require "rspec"

describe Message do

  it "should reference a sender and one or more receivers" do
    sender  = test_user "Sender", "secret"
    receiver1= test_user "Receiver1", "secret"
    receiver2= test_user "Receiver2", "secret"

    m=Message.create( sender_id: sender.to_param, receiver_ids: [receiver1.to_param, receiver2.to_param], subject: "Testmessage", body: "Lorem ipsum")
    [receiver1, receiver2].each do |receiver|
      receiver.received_messages.first.sender.should == sender
      receiver.received_messages.first.subject.should == "Testmessage"
      receiver.received_messages.first.body.should == "Lorem ipsum"
    end
  end
end