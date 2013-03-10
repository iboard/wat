class UserInvitationValidator < ActiveModel::Validator
  def validate(record)
    if Settings.public_sign_up == 'disabled'
      _identity   = Identity.where(:name => record.name).first
      if _identity
        _invitation = ContactInvitation.where( :token => _identity[:invitation_token]).first
        record.errors.add(:base, :invitation_missing) unless _invitation
      else
        record.errors.add(:base, :identity_missing)
      end
    end
  end
end