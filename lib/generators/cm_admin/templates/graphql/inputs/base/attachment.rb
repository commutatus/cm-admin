module Types
  module Inputs
    module Base
      class Attachment < Types::BaseInputObject
        graphql_name 'AttachmentInput'

        description 'Attributes needed to attach a file'

        argument :filename,   String, nil,  required: true
        argument :content,    String, nil,  required: true
      end
    end
  end
end

