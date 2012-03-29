require "bundler/capistrano"

# SETUP SECTION =================================================
server "andi.altendorfer.at", :web, :app, primary: true

set :virtual_host, "andi.altendorfer.at"
set :cluster_ports, [3000,3001,3002]
set :bind_ip, "0.0.0.0"
set :application, "andi"
set :user, 'deployer'
set :deploy_to, "/home/#{user}/apps/#{application}"
set :source_repository, "wat" 
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository, "git@github.com:iboard/#{source_repository}.git"
set :branch, "master"
# END SETUP SECTION =============================================


load "config/recipes/base"

# LOAD RECIPES FOR A WEBRICK-SERVER WITH APACHE PROXY-BALANCER
load "config/recipes/virtual_host_proxy_balancer"
load "config/recipes/webrick"

# NOT YET AVAILABLE BUT COMMING SOON
#load "config/recipes/unicorn"  
# LOAD RECIPES FOR APACHE AND PHUSION PASSENGER
# disable proxy-balancer-section above when enabling this lines 
# load "config/recipes/virtual_host_passenger"
# load "config/recipes/passenger"


default_run_options[:pty] = true
ssh_options[:forward_agent] = true

before "deploy:assets:precompile", "bundle:install"
after "deploy", "deploy:cleanup" # keep 5 versions only

