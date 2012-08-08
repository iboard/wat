# -*- encoding : utf-8 -*-
#
# Defines methods and extensions for a Monoid::Versioning
# to support siple usage to access fields in versions
#
module Versions

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
  
  def self.included(base)
    base.class_eval do

      def available_versions
        self.versions.map(&:version) + [self.version]
      end

      def get_version_of_fields(version,locale,*fields)
        if fields.count == 1
          get_version_of_field(version,locale,fields.first)
        else
          _fields = []
          for field in fields
            _fields << get_version_of_field(version,locale,field)
          end
          _fields
        end
      end

      def restore_version(_new_current_version)
        _update_hash = {}
        self.attributes.reject{|k,v| %w(_id banner versions position).include?(k)}.each do |key, value|
          _new_value = _new_current_version.version.send(key.to_sym)
          if self.class.localized_fields.include?(key)
            _new_value = _new_current_version.send(key.to_sym)
            if _new_value
              begin
                _update_hash[key.to_sym] = eval(_new_value)
              rescue SyntaxError
                puts "CAN NOT INTERPRET #{_new_value.inspect}"
              rescue => e
                _update_hash[key.to_sym] = _new_value
              end
            else
              _update_hash[key.to_sym] = nil
            end
          else
            _update_hash[key.to_sym] = _new_value
          end
        end
        Rails.logger.warn "RESTORE VERSION #{_new_current_version.version.version}: UPDATE_HASH=#{_update_hash.inspect}"
        self.update_attributes(_update_hash)
      end



      private
      def get_version_of_field(version,locale,field)
        _version = eval self.versions[version].send(field.to_sym)
        _version[locale.to_s]
      rescue => e
        raise VersionError.new version, self
      end

    end
  end

end