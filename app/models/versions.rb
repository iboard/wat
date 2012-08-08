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