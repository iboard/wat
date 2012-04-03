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
            process = `ps xa|grep "server -d -p #{port} -b #{bind_ip} --environment=production --pid=#{pidpath}"`
            pid = process.strip.split(/\b/)[0]
            puts "Found running process at #{process}"
            begin
              run "kill -9 #{pid}"
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