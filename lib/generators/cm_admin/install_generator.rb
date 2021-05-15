require 'rails/generators'

module CmAdmin
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def copy_initializer
        copy_file 'cm_admin_initializer.rb', 'config/initializers/cm_admin.rb'
        route 'mount CmAdmin::Engine => "/cm_admin"'
      end
    end
  end
end
