require 'rails/generators'

module CmAdmin
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def copy_initializer
        generate 'action_text:install'
        copy_file 'cm_admin_initializer.rb', 'config/initializers/zcm_admin.rb'
        copy_file 'custom.js', 'app/assets/javascripts/cm_admin/custom.js'
        copy_file 'custom.css', 'app/assets/stylesheets/cm_admin/custom.css'
        copy_file 'actiontext.scss', 'app/assets/stylesheets/cm_admin/actiontext.scss'
        remove_file 'app/assets/stylesheets/actiontext.scss'
        copy_file 'application_policy.rb', 'app/policies/application_policy.rb'
        route 'mount CmAdmin::Engine => "/admin"'
        generate 'migration', 'CreateFileImport associated_model_name:string added_by_id:integer'
        rake 'db:migrate'
      end
    end
  end
end