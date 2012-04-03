namespace :webrick do

  %w[start stop restart].each do |command|
    task command, roles: :web do
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
            # try to kill with ps
            run "ps xa|grep 'server.*#{port}.*#{bind_ip}.*production.*#{port}.pid'|grep -v 'grep' > /tmp/_old_pid"
            begin
              run "xargs --arg-file=/tmp/_old_pid kill -9 && rm -f /tmp/_old_pid"
            rescue => f
              puts "Exception: #{f.inspect}"
            end
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