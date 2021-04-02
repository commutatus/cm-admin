require 'cm_admin/version'
require 'cm_admin/engine'
require 'cm_admin/model'
require 'cm_admin/config'

module CmAdmin
  class Error < StandardError; end

  mattr_accessor :layout

  class << self
    attr_accessor :configuration
    def configuration
      @configuration ||= Configuration.new
    end

    def reset
      @configuration = Configuration.new
    end

    def configure
      yield(configuration)
    end

    def models
      CmAdmin.configuration.included_models.collect { |m| model(m) }
    end

    def model(entity)
      CmAdmin::Model.new(entity)
    end
  end

end
