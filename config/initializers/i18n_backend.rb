def get_redis_db_id
  _yml_file = File.expand_path('../../redis.yml', __FILE__)
  if File.exist?(_yml_file)
    yml = YAML.load( File.read(_yml_file) )
    db = yml[Rails.env]['db']
    Rails.logger.info("Using Redis database #{db} as defined in #{_yml_file}")
    db
  else
    Rails.logger.warn("File #{_yml_file} doesn't exist. Using default Redis database (0)")
    0
  end
end

TRANSLATION_STORE = Redis.new(db: get_redis_db_id, thread_safe: true)
I18n.backend = I18n::Backend::Chain.new(I18n::Backend::KeyValue.new(TRANSLATION_STORE), I18n.backend)


