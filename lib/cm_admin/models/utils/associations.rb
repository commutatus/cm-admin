module CmAdmin
  module Models
    module Utils
      module Associations
        extend ActiveSupport::Concern

        def validation_for_association
          return unless field_type.to_s == "association"

          raise ArgumentError, 'Expected association_name and association_type to be present' if association_name.nil? || association_type.nil?

          if association_type.to_s == 'polymorphic'
            raise ArgumentError, "Expected field_name - #{field_name} - to be an array of hash. Eg, [{table_name_1: 'column_name_1'}, {table_name_2: 'column_name_2'}]" unless field_name.is_a?(Array)

            field_name.each do |element|
              raise ArgumentError, "Expected element #{element} to be a hash. Eg, [{table_name_1: 'column_name_1'}, {table_name_2: 'column_name_2'}]" unless element.is_a?(Hash)
            end
          elsif ['belongs_to', 'has_one'].include? association_type.to_s
            raise ArgumentError, "Expected field_name - #{field_name} to be a String or Symbol" unless field_name.is_a?(Symbol) || field_name.is_a?(String)
          end
        end
      end
    end
  end
end
