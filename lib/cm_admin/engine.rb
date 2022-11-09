require 'rails'
require 'importmap-rails'

module CmAdmin
  class Engine < Rails::Engine
    isolate_namespace CmAdmin

    config.app_middleware.use(
      Rack::Static,
      # note! this varies from the webpacker/engine documentation
      urls: ["/cm-admin-packs"], root: CmAdmin::Engine.root.join("public")
    )

    initializer 'RailsAdmin precompile hook', group: :all do |app|
      app.config.assets.precompile += %w(
        cm_admin/cm_admin.css
        cm_admin/custom.js
        cm_admin/custom.css
      )
    end

    if Rails::VERSION::MAJOR == 6
      initializer "webpacker.proxy" do |app|
        insert_middleware = begin
          CmAdmin.webpacker.config.dev_server.present?
        rescue
          nil
        end
        next unless insert_middleware

        app.middleware.insert_before(
          0, Webpacker::DevServerProxy, # "Webpacker::DevServerProxy" if Rails version < 5
          ssl_verify_none: true,
          webpacker: CmAdmin.webpacker
        )
      end
    elsif Rails::VERSION::MAJOR == 7
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
    end

    def mount_path
      CmAdmin::Engine.routes.find_script_name({})
    end

  end
end
