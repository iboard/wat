# This is an example which deploys to a local running debian-server
# In my case on a mac OS X host running debian in a VMWare-box.
# This config assumes you have configured this local-host in your dns or hosts-file
# e.g. in /etc/hosts => 172.16.103.131  debian64.local
#


### HOW TO DEPLOY
#
#  Prepare:
#    * A server which runs an Apache web-server, rvm, and mongo DB
#    * I for one prepared a VMWare-template from which I start
#    * Otherwise you may add capistrano recipes to do this task
#
server "debian64.local", :web, :app, primary: true
set :virtual_host, "debian64.local"
set :cluster_ports, [3000,3001,3002]
set :bind_ip, "0.0.0.0"
set :application, "watdemo"
set :user, 'deployer'
set :deploy_to, "/home/#{user}/apps/#{application}"
set :source_repository, "wat"
set :deploy_via, :remote_cache
set :use_sudo, false
