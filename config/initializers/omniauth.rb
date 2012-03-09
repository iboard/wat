require 'openid/store/filesystem'

Rails.application.config.middleware.use OmniAuth::Builder do

  configure do |config|
    config.path_prefix = '/auth' if Rails.env == 'production'
  end


  Secrets::secret['omniauth'].each do |service, definition|
    provider service.to_sym, definition['key'], definition['secret']
  end

  if Secrets::secret['openid']
    _store = File::join(Rails.root, Secrets::secret['openid']['store'])
    provider :openid, :store => OpenID::Store::Filesystem.new(_store)
  end

  provider :identity, :fields => [:name], :auth_key => 'name', on_failed_registration: lambda { |env|    
    IdentitiesController.action(:new).call(env)
  }

end
