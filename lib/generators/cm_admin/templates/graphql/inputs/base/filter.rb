module Types
  module Inputs
    module Base
      class Filter < Types::BaseInputObject
        graphql_name 'BaseFilterInput'

        description 'Attributes needed for filtering items'

        argument :ids,          [Integer],  nil,  required: false
        argument :q,            String,     nil,  required: false
      end
    end
  end
end

