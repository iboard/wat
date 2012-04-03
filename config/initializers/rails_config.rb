::VALIDATE_EMAIL_REGEX = /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i

RailsConfig.setup do |config|
  config.const_name = "Settings"
end