namespace :deploy do
  desc "Deploy application config from config/servers/configs"
  task :application_config, :roles => :app do
    config_path = File.expand_path("../../servers/configs/#{virtual_host}",__FILE__)
    if File.directory?( config_path )
      %w( mongoid.yml secrets.yml settings.yml settings/production.yml ).each do |config|
        puts "INSTALL LOCAL/SECRET CONFIG FROM " + File.join(config_path,(config+".erb"))
        template config+".erb", "/tmp/#{File::basename(config)}", config_path
        run "#{sudo} mv /tmp/#{File::basename(config)} #{shared_path}/config/#{config}"
        run "#{sudo} chmod 600 #{shared_path}/config/#{config}"
      end
    else
      puts "=============================================================="
      puts "No config prepared in #{config_path}"
      puts "PLEASE EDIT FILES IN #{shared_path} ON YOUR "
      puts "SERVER BEFORE deploy:cold"
      puts "=============================================================="
    end
  end
end
after "deploy:setup_config", "deploy:application_config"

#after("deploy:update_code", "deploy:build_missing_paperclip_styles")