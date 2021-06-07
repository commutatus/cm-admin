require 'slim'
require 'cm_admin/version'
require 'cm_admin/engine'
require 'cm_admin/model'
require 'cm_admin/view_helpers'
require 'cm_admin/utils'

module CmAdmin
  class Error < StandardError; end

  mattr_accessor :layout
  mattr_accessor :included_models, :cm_admin_models
  @@included_models ||= []
  @@cm_admin_models ||= []

  class << self
    def webpacker
      @webpacker ||= ::Webpacker::Instance.new(
        root_path: CmAdmin::Engine.root,
        config_path: CmAdmin::Engine.root.join('config', 'webpacker.yml')
      )
    end

    def setup
      yield self
    end

    def config(entity, &block)
      if entity.is_a?(Class)
        @@cm_admin_models << CmAdmin::Model.new(entity, &block)
      end
    end
  end

end
