require 'rails'
require "importmap-rails"

module CmAdmin
  class Engine < Rails::Engine
    isolate_namespace CmAdmin

    initializer "cm_admin.importmap", before: "importmap" do |app|
      # NOTE: this will add pins from this engine to the main app
      # https://github.com/rails/importmap-rails#composing-import-maps
      app.config.importmap.paths << root.join("config/importmap.rb")

      # NOTE: something about cache; I did not look into it.
      # https://github.com/rails/importmap-rails#sweeping-the-cache-in-development-and-test
      app.config.importmap.cache_sweepers << root.join("app/assets/javascripts")
    end

    # NOTE: add engine manifest to precompile assets in production
    initializer "cm_admin.assets" do |app|
      app.config.assets.precompile += %w[cm_admin_manifest]
    end


    initializer 'RailsAdmin precompile hook', group: :all do |app|
      app.config.assets.precompile += %w(
        cm_admin/cm_admin.css
        cm_admin/custom.js
        cm_admin/custom.css
      )
    end


    def mount_path
      CmAdmin::Engine.routes.find_script_name({})
    end

  end
end
