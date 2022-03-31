require 'rails/generators'

module CmAdmin
  module Generators
    class PolicyGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)

      def copy_policy_files
        template "policy.rb", "app/policies/cm_admin/#{file_name}_policy.rb"
      end
    end
  end
end