# @param [String] from - the erb-template to read from
# @param [String] to - where to put the rendered result
def template(from, to=nil)
  erb = File.read(File.expand_path("../templates/#{from}",__FILE__))
  result = ERB.new(erb).result(binding)
  if to
    put result, to  
  else
    result
  end
end


namespace :deploy do

  desc "Install your server"
  task :install do
    puts "NO INSTALL RECIPIENT IS DEFINED YET"
    puts "SEE #{__FILE__} :deploy:install AND SETUP REQIRED STEPS THERE"
  end

  desc "Setup the config-files on the server with example-defaults"
  task :setup_config, roles: :app do
    run "mkdir -p #{shared_path}/config"
    put File.read("config/mongoid.example.yml"), "#{shared_path}/config/mongoid.yml"
    put File.read("config/test_secrets.yml"), "#{shared_path}/config/secrets.yml"
    put File.read("config/settings_sample.yml"), "#{shared_path}/config/settings.yml"

    run "mkdir -p #{shared_path}/config/settings"
    put File.read("config/settings/production.yml_sample"), "#{shared_path}/config/settings/production.yml"

    puts "=============================================================="
    puts "EDIT FILES IN #{shared_path} ON YOUR "
    puts "SERVER BEFORE deploy:cold"
    puts "=============================================================="
  end
  after "deploy:setup", "deploy:setup_config"

  desc "Symlink config-files after update"
  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/mongoid.yml #{release_path}/config/mongoid.yml"
    run "ln -nfs #{shared_path}/config/secrets.yml #{release_path}/config/secrets.yml"
    run "ln -nfs #{shared_path}/config/settings.yml #{release_path}/config/settings.yml"
    run "ln -nfs #{shared_path}/config/settings/production.yml #{release_path}/config/settings/production.yml"
  end
  after "deploy:finalize_update", "deploy:symlink_config"

  [:start, :stop, :restart].each do |t|
    desc "#{t} task is a no-op with proxy_balancer"
    task t, :roles => :app do ; end
  end
  
end