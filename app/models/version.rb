# -*- encoding : utf-8 -*-

# Wraps a Mongoid::Dcoument with Mongoid::Versioning
class Version

  attr_reader :object, :version, :current_version

  def initialize(_object, _version)
    @object = _object
    @version= _object.versions.detect { |_v| _v.version == _version }
    @current_version = (_version == _object.version ? true : false)
    raise Versions::VersionError.new( _version, _object) unless @current_version || @version
  end

  def method_missing(*args, &block)
    if current_version
      @object.send(*args, &block)
    else
      if localized?(args.first) 
        _field = @version.send("#{args.first}_translations".to_sym)
        _options = _field.first[1]
        if _options.class == String
          _field = eval(_options)
        end
        Rails.logger.info "TRANSLATIONS => " + _field.inspect + "( #{_field.class.to_s} )"
        _field[I18n.locale.to_s] if _field
      else
        @version.send(*args, &block)
      end
    end
  end

  private
  def localized?(key)
    _field = eval("#{object.class}.fields['#{key}']")
    _field.class == Mongoid::Fields::Internal::Localized
  end



end

