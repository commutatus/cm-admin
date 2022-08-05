module Types
  module Inputs
    module Base
      class Paging < Types::BaseInputObject
        graphql_name 'PagingInput'

        description 'Attributes needed for paginating list of items'

        argument :page_no,      Integer, nil,  required: true
        argument :per_page,     Integer, nil,  required: false
      end
    end
  end
end

