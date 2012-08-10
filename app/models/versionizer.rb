# -*- encoding : utf-8 -*-
#
# Defines methods and extensions for a Monoid::Versioning
# to support using class Version
#
module Versionizer

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

    end
  end

end