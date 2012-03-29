namespace :webrick do

  %w[start stop restart].each do |command|
    task command, roles: :app do
      case command
      when 'start'
        for port in cluster_ports
          pidpath = "#{current_path}/tmp/pids/#{port}.pid"
          puts "Starting WEBrick at port #{port} on #{bind_ip} as deamon"
          run "cd #{current_path}; rails server -d -p #{port} -b #{bind_ip} --environment=production --pid=#{pidpath}"
        end
      when 'stop'
        for port in cluster_ports
          pidpath = "#{current_path}/tmp/pids/#{port}.pid"
          begin
            pid = File.read(pidpath)
            puts "Killing WEBrick with pid #{pid} (read from #{pidpath})"
            run "kill -9 #{pid}"
          rescue => e
            puts "Server on port #{port} already stopped. => #{e.inspect}"
          end
        end
      when 'restart'
        stop
        start
      end
    end
  end
  after "deploy:restart", "webrick:restart"
  after "deploy:cold", "webrick:start"

end