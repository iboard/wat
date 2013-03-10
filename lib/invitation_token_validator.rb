# -*- encoding : utf-8 -*-"

class InvitationTokenValidator < ActiveModel::Validator
  def validate(record)
    if Settings.public_sign_up == 'disabled'
      if record.invitation_token.blank?
        record.errors.add(:invitation_token, :cant_be_blank)
      else
        unless ContactInvitation.where(token: record.invitation_token).first
          record.errors.add(:invitation_token, :token_not_found)
        end
      end
    end
  end
end

