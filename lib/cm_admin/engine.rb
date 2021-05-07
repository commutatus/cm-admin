require 'rails'
module CmAdmin
  class Engine < Rails::Engine
    isolate_namespace CmAdmin

    initializer 'RailsAdmin precompile hook', group: :all do |app|
      app.config.assets.precompile += %w(
        cm_admin/cm_admin.css
      )
    end

    def mount_path
      CmAdmin::Engine.routes.find_script_name({})
    end

  end
end
