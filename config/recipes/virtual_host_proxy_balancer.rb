namespace :deploy do

  desc "Enable neccesary apache-modules on the server"
  task :install_proxy_module, roles: :web do
    run "#{sudo} a2enmod proxy"
    run "#{sudo} a2enmod proxy_balancer"
    run "#{sudo} a2enmod rewrite"
  end
  after "deploy:install", "deploy:install_proxy_module"

  desc "Install proxy-configs"
  task :install_proxy_configs, roles: :web do
    %w( proxy_balancer.load proxy.conf proxy_http.load proxy.load ).each do |config|
      template "apache_#{config}.erb", "/tmp/apache_#{config}"
      run "#{sudo} mv /tmp/apache_#{config} /etc/apache2/mods-available/#{config}"
      run "#{sudo} [ -f /etc/apache2/mods-enabled/#{config} ] && #{sudo} rm /etc/apache2/mods-enabled/#{config}"
      run "#{sudo} ln -s /etc/apache2/mods-available/#{config} /etc/apache2/mods-enabled/#{config}"
    end
    run "#{sudo} apache2ctl graceful"
  end
  after "deploy:install_proxy_module", "deploy:install_proxy_configs"


  desc "Enable a virtual host for the application and restart apache"
  task :setup, roles: :web do
    template "apache_site_conf.erb", "/tmp/apache_site_conf"
    run "#{sudo} mv /tmp/apache_site_conf /etc/apache2/sites-enabled/#{application}"
    run "#{sudo} apache2ctl graceful"
  end
  after "deploy:setup", "virtual_host_proxy_balancer:setup"

  desc "Generate the virtual host config and show but not update on server"
  task :show do
    puts "=============================================================="
    puts "This normaly goes to /etc/apache2/sites-enabled/#{application}"
    puts "--------------------------------------------------------------"
    puts template "apache_site_conf.erb"
    puts "=============================================================="
  end

end