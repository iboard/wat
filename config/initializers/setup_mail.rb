ActionMailer::Base.smtp_settings = {
  :address              => Settings.smtp_server,
  :port                 => Settings.smtp_port,
  :domain               => Settings.smtp_domain,
  :user_name            => Settings.smtp_user,
  :password             => Settings.smtp_password,
  :authentication       => Settings.smtp_authentication,
  :enable_starttls_auto => Settings.smtp_enable_starttls_auto
}

ActionMailer::Base.default_url_options[:host] = Settings.smtp_host
Mail.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?
