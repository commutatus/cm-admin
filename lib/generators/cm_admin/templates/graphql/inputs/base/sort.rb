module Types
  module Inputs
    module Base
      class Sort < Types::BaseInputObject
        graphql_name 'SortInput'

        description 'Attributes needed for sorting the list of items'

        argument :column,         Types::Enums::Base::SortColumn, nil, required: true
        argument :direction,      Types::Enums::Base::SortDirection, nil, required: true
      end
    end
  end
end

