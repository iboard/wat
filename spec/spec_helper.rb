require 'rubygems'
require 'spork'
require File.expand_path '../support/wat_spec', __FILE__

#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'


Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'capybara/rspec'
  require "selenium-webdriver"
  require 'email_spec'
  require 'rspec/autorun'
  require "paperclip/matchers"

  RSpec.configure do |config|
    config.include(EmailSpec::Helpers)
    config.include(EmailSpec::Matchers)
    config.include(Paperclip::Shoulda::Matchers)
    # config.fixture_path = "#{::Rails.root}/spec/fixtures"
    # config.use_transactional_fixtures = true
    # config.infer_base_class_for_anonymous_controllers = true
    config.mock_with :rspec

    Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

    # Clean up the database
    require 'database_cleaner'
    config.before(:suite) do
      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.orm = "mongoid"
      Capybara.javascript_driver = :webkit
    end

    config.include(MailerMacros)

    config.before(:each) do
      DatabaseCleaner.clean
      reset_email

      Doorkeeper.configure do |doorkeeper|
        doorkeeper.doorkeeper ||= Doorkeeper::TimelineLogger.new
      end
    end

  end
end

Spork.each_run do
  # Check if any model changed
  Dir.glob("#{Rails.root}/app/models/*.rb").sort.each { |file| load file }

  # Reload Settings
  Settings.reload_from_files(
      Rails.root.join("config", "settings.yml").to_s,
      Rails.root.join("config", "settings", "#{Rails.env}.yml").to_s,
      Rails.root.join("config", "environments", "#{Rails.env}.yml").to_s
  )

  Doorkeeper.configure do |doorkeeper|
    doorkeeper.doorkeeper ||= Doorkeeper::TimelineLogger.new
  end

end

