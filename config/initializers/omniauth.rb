# -*- encoding : utf-8 -*-
require 'openid/store/filesystem'

Rails.application.config.middleware.use OmniAuth::Builder do

  unless defined?(OpenSSL::SSL::VERIFY_PEER) && OpenSSL::SSL::VERIFY_PEER == OpenSSL::SSL::VERIFY_NONE
    OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
  end

  configure do |config|
    config.path_prefix = '/auth' #unless Rails.env == 'test'
    config.logger = Rails.logger
  end


  Secrets::secret['omniauth'].each do |service, definition|
    provider service.to_sym, definition['key'], definition['secret']
  end

  if Secrets::secret['openid']
    _store = File::join(Rails.root, Secrets::secret['openid']['store'])
    provider :openid, :store => OpenID::Store::Filesystem.new(_store)
  end

  provider :identity,
    :fields => [:name, :invitation_token],
    :auth_key => 'name', on_failed_registration: lambda { |env| IdentitiesController.action(:new).call(env) }

end


module OmniAuth
  module Strategies
    autoload :Campus, File::join(Rails.root,'lib/campus_authorization')
  end
end

