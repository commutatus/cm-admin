module CmAdmin
  module Models
    class NestedField

      # NestedField is like a container to hold Field and FormField object

      attr_accessor :field_name, :display_type, :fields, :associated_fields, :parent_field, :header, :label

      def initialize(field_name, attributes={})
        @field_name = field_name
        set_default_values
        attributes.each do |key, value|
          self.send("#{key.to_s}=", value)
        end
      end

      def set_default_values
        self.display_type = :table
        self.fields = []
        self.associated_fields = []
      end

    end
  end
end