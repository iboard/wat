require 'rbconfig'
HOST_OS = RbConfig::CONFIG['host_os']
source 'https://rubygems.org'

gem 'rails', '3.2.2'
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'

  # 2.1 has no-go issues with dropdown menus. Stay at 2.0.4 until 2.1.1
  gem 'bootstrap-sass', '2.0.4.2' #~> 2.1.0.0'
end

gem 'jquery-rails'
gem "haml", ">= 3.1.4"
gem "haml-rails", ">= 0.3.4", :group => :development
gem "rspec-rails", ">= 2.8.1", :group => [:development, :test]
gem "database_cleaner", ">= 0.7.1", :group => :test
gem "mongoid-rspec", "~> 1.4.4", :group => :test
gem "factory_girl_rails", ">= 1.7.0", :group => :test
gem "email_spec", ">= 1.2.1", :group => :test
gem "guard", ">= 0.6.2", :group => :development  
case HOST_OS
  when /darwin/i
    # Original for app-template
    # gem 'rb-fsevent', :group => :development
    # gem 'growl', :group => :development
    # gem 'ruby_gntp', :group => :development

    # changed for capistrano
    gem 'rb-fsevent', :group => :development
    gem 'growl', :group => :development
    gem 'ruby_gntp', :group => :development
    #gem 'libnotify', :group => :development
    #gem 'rb-inotify', :group => :development
    gem 'therubyracer', '~> 0.10.2', :group => :assets

  when /linux/i
    # Original for app-template
    # gem 'libnotify', :group => :development
    # gem 'rb-inotify', :group => :development
    # gem 'therubyracer', '~> 0.10.2', :group => :assets

    # changed for capistrano
    gem 'rb-fsevent', :group => :development
    gem 'growl', :group => :development
    gem 'ruby_gntp', :group => :development
    #gem 'libnotify', :group => :development
    #gem 'rb-inotify', :group => :development
    gem 'therubyracer', '~> 0.10.2', :group => :assets
 
  when /mswin|windows/i
    gem 'rb-fchange', :group => :development
    gem 'win32console', :group => :development
    gem 'rb-notifu', :group => :development
end

# Test environment
group :test do
  gem "guard-bundler", ">= 0.1.3", :group => :development
  gem "guard-rails", ">= 0.0.3", :group => :development
  gem "guard-livereload", ">= 0.3.0", :group => :development
  gem "guard-rspec", ">= 0.4.3", :group => :development
  gem "capybara"
  gem "capybara-webkit"
  gem "launchy"
  gem "spork"
  gem "guard-spork"
  gem "growl"
  gem 'ruby_gntp'
end

group :development do
  gem "guard-spork"
  gem "pow"
  gem "syntax"
end

# Andi's GEMs
gem "jsort", "~> 0.0.4"

# Application
gem "bson_ext", ">= 1.5.2"
gem "mongoid", "~> 2.4.4"
gem "mongoid-paperclip", :require => 'mongoid_paperclip'
gem "yard"
gem "redcarpet"
gem 'albino'
gem 'nokogiri'
gem 'simple_form'
gem 'rails_config'
gem 'capistrano'
gem "ckeditor", "~> 3.7.1"
gem "redis"


# Authentication
gem "omniauth", ">= 1.0.2"
gem "omniauth-twitter"
gem "omniauth-facebook"
gem "omniauth-linkedin"
gem "omniauth-37signals"
gem "omniauth-github"
gem "omniauth-openid"
gem "omniauth-google-oauth2"
gem "omniauth-tumblr"
gem "omniauth-foursquare"
gem "omniauth-identity"
gem 'bcrypt-ruby', '~> 3.0.0'
