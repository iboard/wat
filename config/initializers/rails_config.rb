unless defined? ::VALIDATE_EMAIL_REGEX
  ::VALIDATE_EMAIL_REGEX = /\A[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}\Z/i
end

RailsConfig.setup do |config|
  config.const_name = "Settings"
end