# -*- encoding : utf-8 -*-

# Wraps a Mongoid::Dcoument with Mongoid::Versioning
class Version

  attr_reader :object, :version, :current_version

  def initialize(_object, _version)
    @object = _object
    if _object.version == _version
      @version = @object
    else
      @version= @object.versions.detect { |_v| _v.version == _version }
    end
    raise Versions::VersionError.new( _version, _object) unless @version
  end

  def current_version?
    @current_version ||= version.version == object.version
  end

  # make this version a new (current) version of wrapped object
  def restore
    _update_hash = {}
    object.attributes.reject {|k,v| object.class.ignore_fields_on_restore.include?(k)}.each do |key, value|
      _update_hash.merge! get_restore_hash(key,value)
    end
    object.update_attributes(parameterize(_update_hash))
  end

  # delegate to wrapped object and parameterize embedded objects and localized fields
  def method_missing(*args, &block)
    if current_version?
      object.send(*args, &block)
    else
      if localized?(args.first)
        _field_translations = eval_localized_string(args.first)
        if args.first !~ /_translations\Z/
          _field = _field_translations[I18n.locale.to_s]
        end
      else
        version.send(*args, &block)
      end
    end
  end

private

  def localized?(key)
    return true if key =~ /_translations\Z/
    field_type_of_key(key).class == Mongoid::Fields::Internal::Localized
  end

  def field_type_of_key(key)
    eval("#{object.class}.fields['#{key}']")
  end

  def get_restore_hash(key, value)
    { key.to_sym => self.send(key.to_sym) }
  end

  # Mongoid::Versioning + Localize fields packs values as:
  # "xy => { en: 'english', de: 'deutsch' }"
  # We need the inner hash { en: 'english', de: 'deutsch' } only
  # @return String of the current locale eg 'english' of { en: 'english', de: 'deutsch' }
  def eval_localized_string(key)
    key = key.to_s + "_translations" unless key =~ /_translations\Z/
    _hash = eval_value( version.send("#{key}".to_sym) ) #=> String "{ xy => "'{ en: xxx, de: yyy }'"}"
    _entry = eval_value(_hash.first)                    #=> Hash    { xy => "{en: xxx, de: yyy }" }
    eval_value(_entry[1])                               #=> Hash    { en: xxx, de: yyy }
  end

  # We need a hash of embedded objects if the field is mentioned
  # in objects method/array parameterize_fields
  def parameterize(hash)
    _hash = {}
    hash.each do |k,v|
      _hash[k.to_sym] = parameterized?(k) ? attributes_to_hash(v) : v
    end
    _hash
  end
  
  def parameterized?(key)
    object.class.parameterize_fields.include?(key.to_s)
  end

  def attributes_to_hash(v)
    _hash = {}
    v.attributes.each do |k,v|
      case v.class.to_s
      when "BSON::ObjectId"
        _hash[k.to_sym] = v.to_s unless k == '_id'
      else
        _hash[k.to_sym] = v
      end
    end
    _hash
  end


  def eval_value(value)
    begin
      eval(value)
    rescue SyntaxError
      # NOOP
    rescue => e
      value
    end
  end

end

