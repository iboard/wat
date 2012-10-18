# -*- encoding : utf-8 -*-
module Redirect_test

  # Module Redirect
  # ================================
  # 
  # Monkey-patch the class HomeController
  module RootPath

    # def self.included(base)
    #   base.send(:include, InstanceMethods)
    #   base.alias_method_chain :index, :original_index
    # end

    # module InstanceMethods
    #   # override the 'index' method
    #   def index_with_original_index
    #     # do stuff
    #     Rails.logger.info("Redirect.RootPath InstanceMethods was called for HomeController")
    #     original_index
    #   end
    # end

    # include as: HomeController.send(:include, Redirect::RootPath) within environment.rb
    #         or: class Railtie < ::Rails::Railtie -> it works but:
    #   to make changes work restart rails server is needed
    # include as: include Redirect::RootPath within HomeController it doesn't work

    # def index
    #   Rails.logger.info("Redirect.RootPath index was called for HomeController")
    #   # _original_index
    #   # home_index
    #   super
    #   # redirect_to contacts_path
    # end

    def self.included base
      raise "Module Redirect::RootPath can be included to class HomeController only" unless base == HomeController
      Rails.logger.info("Redirect.RootPath self.included base was called for HomeController")

      base.class_eval do
        # monkey-patch class HomeController 

        alias_method :original_index, :index
        def index
          Rails.logger.info("Redirect.RootPath index was called for HomeController")
          original_index
          # home_index
          # redirect_to contacts_path
        end
      
      end # end base.class_eval

    end

  end

  # class Railtie < ::Rails::Railtie

  #   # The block you pass to this method will run for every request in
  #   # development mode, but only once in production.
  #   config.to_prepare do
  #     # SomeModel.send(:include, MyModule::SomeModelExtensions)
  #     Rails.logger.info("Redirect Railtie < ::Rails::Railtie was called for HomeController")
  #     HomeController.send(:include, Redirect::RootPath)
  #   end

  # end

end     
