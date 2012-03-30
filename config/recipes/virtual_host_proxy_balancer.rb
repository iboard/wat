namespace :virtual_host_proxy_balancer do

  desc "Enable neccesary apache-modules on the server"
  task :install, roles: :web do
    run "#{sudo} a2enmod proxy_balancer"
    run "#{sudo} a2enmod rewrite"
  end
  after "deploy:install", "virtual_host:install"
  

  desc "Enable a virtual host for the application and restart apache"
  task :setup, roles: :web do
    template "apache_site_conf.erb", "/tmp/apache_site_conf"
    run "#{sudo} mv /tmp/apache_site_conf /etc/apache2/sites-enabled/#{application}"
    run "#{sudo} apache2ctl graceful"
  end
  after "deploy:setup", "virtual_host:setup"

  desc "Generate the virtual host config and show but not update on server"
  task :show do
    puts "=============================================================="
    puts "This normaly goes to /etc/apache2/sites-enabled/#{application}"
    puts "--------------------------------------------------------------"
    puts template "apache_site_conf.erb"
    puts "=============================================================="
  end

end