class ContactInvitation

  include Mongoid::Document
  include Mongoid::Timestamps

  field  :recipient_email
  validates_format_of  :recipient_email, :with => ::VALIDATE_EMAIL_REGEX, :allow_nil => false

  field   :sender_id, class: BSON::ObjectId
  def sender
    User.find(self.sender_id)
  end
  def sender=(_sender)
    self.sender_id = _sender._id
  end

  field  :token
  before_validation :generate_token

  after_create :send_mail

  private
  def generate_token
    self.token ||= SecureRandom::hex(10)
  end

  def send_mail
    UserMailer.send_contact_invitation(self).deliver
  end

end  
