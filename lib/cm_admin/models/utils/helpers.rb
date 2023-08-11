module CmAdmin
  module Models
    module Utils
      module Helpers
        extend ActiveSupport::Concern

        # Returns the humanized value of the field.
        def humanized_field_value(name, capitalize: false)
          name.to_s.humanize(capitalize: capitalize)
        end
      end
    end
  end
end
