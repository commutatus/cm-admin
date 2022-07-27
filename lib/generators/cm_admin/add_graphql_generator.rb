require 'rails/generators'

module CmAdmin
  module Generators
    class AddGraphqlGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def add_graphql
        gem 'graphql'
        gem 'graphql-errors'
        gem 'graphql-rails_logger'
        generate 'graphql:install'
        template 'graphql/graphql_schema.rb', "app/graphql/#{Rails.application.class.module_parent_name.underscore}_schema.rb"
        directory 'graphql/inputs/base', 'app/graphql/types/inputs/base'
        directory 'graphql/enums/base', 'app/graphql/types/enums/base'
        directory 'graphql/objects/base', 'app/graphql/types/objects/base'
        directory 'concerns', 'app/models/concerns'
        copy_file 'graphql/mutations/base_mutation.rb', 'app/graphql/mutations/base_mutation.rb'
        copy_file 'graphql/queries/base_query.rb', 'app/graphql/queries/base_query.rb'
        copy_file 'exceptions/base_exception.rb', 'app/exceptions/base_exception.rb'
      end
    end
  end
end