class UserMailer < ActionMailer::Base
  default from: Settings.smtp_default_from
  def registration_confirmation(user)
    @user = user
    mail(:to => user.email, :subject => "Registered")
  end
end