# -*- encoding : utf-8 -*-"
#
class Message
  include Mongoid::Document
  include Mongoid::Timestamps

  field   :subject
  field   :body

  has_one   :sender,  class_name: "User"
  has_many  :receivers, class_name: "User"

  def sender
    User.find(self.sender_id)
  end

  def receivers
    User.any_in(_id: self.receiver_ids)
  end
end