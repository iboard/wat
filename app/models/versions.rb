# -*- encoding : utf-8 -*-
#
# Defines methods and extensions for a Monoid::Versioning
# to support siple usage to access fields in versions
#
module Versions

  # Version exception

  class VersionError < RuntimeError

    def initialize( version, _object )
      @requested_version = version
      @version = _object.version
      @versions = _object.versions.map(&:version)
    end
    
    def message
      "VERSION #{@requested_version} NOT FOUND: current-version: #{@version} - #available: #{@versions}"
    end

  end


  # Monkey-pactch the base

  def self.included(base)
    base.class_eval do

      def available_versions
        self.versions.map(&:version) + [self.version]
      end

      def restore_version(_version)
        _update_hash = {}
        self.attributes.reject {|k,v| self.class.ignore_fields_on_restore.include?(k)}.each do |key, value|
          _update_hash.merge! get_restore_hash(_version,key,value)
        end
        self.update_attributes(_update_hash)
      end


    private

      def get_restore_hash(_version, key, value)
        _new_value = _version.send(key.to_sym)
        _field = eval( "#{self.class}.fields[key]" )
        if _field && _field.localized?
          _hash_or_value = eval("_version.#{key}_translations")
          { "#{key}_translations".to_sym => prepare_translation_hash(_hash_or_value) }
        else
          { key.to_sym => eval_value(_new_value) }
        end

      end

      def eval_value(_new_value)
        begin
          eval(_new_value)
        rescue SyntaxError
          # NOOP
        rescue => e
          _new_value
        end
      end

      # MongoId will returns a nested String as:
      #   '{ XY => "{ en: ...., de: ....}"'
      # XY is the current locale I18n.locale and we don't care about
      # 1. eval the outer string to hash _temp
      # 2. eval the value of _temp to get the hash we're looking for
      # F*CK
      def prepare_translation_hash(_input)
        _temp =  _input.class == String ?  eval(_input) : _input
        _hash = {}
        begin
          _hash = eval(_temp.first[1])
        rescue SyntaxError
          #noop
        rescue
          _hash = _temp
        end
        _hash
      end

    end
  end

end