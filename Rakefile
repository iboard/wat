#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

task :default => 'tdd:run_all_specs'
require File.expand_path('../config/application', __FILE__)

Wat::Application.load_tasks

