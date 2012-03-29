namespace :virtual_host do

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

end