# -*- encoding : utf-8 -*-

# Wraps a Mongoid::Dcoument with Mongoid::Versioning
class Version

  attr_reader :object, :version, :current_version, :locale

  def initialize(_object, _version, _locale)
    @object = _object
    @version= _object.versions.detect { |_v| _v.version == _version }
    @current_version = _version == _object.version ? true : false
    @locale = _locale
    raise Versions::VersionError.new( _version, _object) unless @current_version || @version
  end

  def method_missing(*args, &block)
    if current_version
      object.send(*args, &block)
    else
      begin
        begin
          _field = eval( version.send(args.first.to_sym) )
          _field[locale.to_s]
        rescue SyntaxError => e
          Rails.logger.warning(e.inspect)
        end
      rescue
        _field = version.send(args.first.to_sym)
      end
    end
  end



end

