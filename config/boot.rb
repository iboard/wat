# -*- encoding : utf-8 -*-
require 'rubygems'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

# If you have any syntax-error in yaml-files, psych will give you strange error-messages
# on top the yaml-file. Enable the next two lines to switch to 'syck' will give you the exact
# line of the syntax-error. But please remark 'syck' when done because it's the standard
# yaml-interpreter and faster.
# require 'yaml'
# YAML::ENGINE.yamler= 'psych'

