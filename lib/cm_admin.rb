require 'slim'
require 'cm_admin/version'
require 'cm_admin/engine'
require 'cm_admin/model'
require 'cm_admin/view_helpers'
require 'cm_admin/utils'
require 'cm_admin/configuration'

module CmAdmin
  class Error < StandardError; end

  mattr_accessor :layout, :authorized_roles
  mattr_accessor :included_models, :cm_admin_models
  @@authorized_roles ||= []
  @@included_models ||= []
  @@cm_admin_models ||= []
  

  class << self

    def configure(&block)
      instance_eval(&block)
    end

    def config
      @config ||= Configuration.new
    end

    def initialize_model(entity, &block)
      if entity.is_a?(Class)
        return if CmAdmin::Model.find_by({name: entity.name})
        config.cm_admin_models << CmAdmin::Model.new(entity, &block)
      end
    end
  end

end
