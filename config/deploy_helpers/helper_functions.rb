def load_target_server
  determine_target do |target|
    load( File.expand_path( "../../servers/#{target}", __FILE__))
  end
end





def determine_target(&block)
  _target = ENV['TARGET'] if ENV['TARGET']
  _target ||= server_configurations.first if server_configurations.count==1
  if !ENV['TARGET'] && server_configurations.count > 0
    puts "!!!CAN'T CONTINUE!!!"
    puts "There are more than one server configurations in config/servers/: " + server_configurations.join(', ').gsub(/\.rb/,'')
    puts "Please provide a target-server through TARGET=....."
    exit 1
  else
    block_given? ? yield(_target+".rb") : _target+".rb"
  end
end

def server_configurations
  return @server_configurations_loaded if @server_configurations_loaded
  @server_configurations_loaded = []
  Dir.new( File.expand_path('../../servers',__FILE__)).each do |filename|
    if filename =~ /\.rb\Z/
      @server_configurations_loaded << filename
    end
  end
end