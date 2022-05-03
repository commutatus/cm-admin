require 'rails/generators'

module CmAdmin
  module Generators
    class PolicyGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)

      def copy_policy_files
        cm_model = CmAdmin::Model.find_by({name: file_name})
        raise "cm_admin is not defined inside #{file_name} model" unless cm_model.present?
        template "policy.rb", "app/policies/cm_admin/#{file_name}_policy.rb"
      end
    end
  end
end