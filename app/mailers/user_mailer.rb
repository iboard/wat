# -*- encoding : utf-8 -*-

class UserMailer < ActionMailer::Base
  default from: Settings.smtp_default_from
  def registration_confirmation(user)
    user.generate_confirm_email_token!
    @user = user
    mail(:to => user.email, :subject => Settings.application_mail_subject_prefix + " Confirm your email-address / Bestätigen Sie Ihre Email-Adresse")
  end

  def send_password_reset_token(user)
    @user = user
    mail(:to => user.email, :subject => Settings.reset_password_subject||'Reset your password / Passwort zurücksetzen')
  end

  def send_contact_invitation(contact_invitation)
    @contact_invitation = contact_invitation
    mail(:to => contact_invitation.recipient_email, :subject => Settings.contact_invitation_subject||'You are invited/Sie wurden eingeladen')
  end
end