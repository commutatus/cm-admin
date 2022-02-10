require 'rails'
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

    def mount_path
      CmAdmin::Engine.routes.find_script_name({})
    end

  end
end
