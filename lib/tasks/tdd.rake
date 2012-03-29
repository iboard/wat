namespace :tdd do

  desc "Run all specs"
  task :run_all_specs do
    puts ""
    puts "================================================================"
    puts "Running all specs. rspec is configured to use --drb by default"
    puts "It's a good idea to start 'bundle exec guard' which will start a"
    puts "rails server instance and spork"
    puts "----------------------------------------------------------------"
    sh "rspec spec/"
  end
end