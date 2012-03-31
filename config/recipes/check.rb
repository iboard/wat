namespace :check do

  desc "Make sure all files are tracked"
  task :untracked_files, roles: [:web,:app] do
    puts "Checking for untracked files ..."
    if `git status` =~ /Untracked files/
      puts "WARNING: There are untracked files!"
      exit
    end
  end
  before "deploy", "check:untracked_files"
  before "deploy:cold", "check:untracked_files"

  desc "Make sure local git is in sync with remote."
  task :revision, roles: :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/#{branch}`
      puts "WARNING: HEAD is not the same as origin/#{branch}"
      puts "Run `git push` to sync changes."
      exit
    end
  end
  before "deploy", "check:revision"
  before "deploy:migrations", "check:revision"
  before "deploy:cold", "check:revision"
end
