require 'rails/generators'

module CmAdmin
  module Generators
    class AddAuthenticationGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      # This generator is used to add authentication, if no auth system is present.
      # Adds authentication through devise and sets up the current user.
      def add_authentication
        gem "devise"
        generate "devise:install"
        model_name = ask("What would you like the user model to be called? [user]")
        generate "devise", model_name
        rake "db:migrate"
        copy_file 'application_controller.rb', 'app/controllers/cm_admin/application_controller.rb'
        copy_file 'authentication.rb', 'app/controllers/concerns/authentication.rb'
        copy_file 'current.rb', 'app/models/current.rb'
        inject_into_file 'app/models/user.rb', before: "end\n" do <<-'RUBY'
  # Remove this once role is setup and mentioned in zcm_admin.rb
  def super_admin?
    true
  end
        RUBY
        end
      end
    end
  end
end