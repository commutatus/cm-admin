require 'rails/generators'

module CmAdmin
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def copy_initializer
        copy_file 'cm_admin_initializer.rb', 'config/initializers/cm_admin.rb'
        copy_file 'custom.js', 'app/assets/javascripts/cm_admin/custom.js'
        copy_file 'custom.css', 'app/assets/stylesheets/cm_admin/custom.css'
        copy_file 'application_policy.rb', 'app/policies/application_policy.rb'
        route 'mount CmAdmin::Engine => "/admin"'
      end
    end
  end
end