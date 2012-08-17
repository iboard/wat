Doorkeeper.configure do |doorkeeper|
  doorkeeper.doorkeeper ||= Doorkeeper::TimelineLogger.new
end