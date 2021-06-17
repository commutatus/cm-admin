module CmAdmin
  module Models
    class Field
      attr_accessor :field_name, :label, :header, :field_type

      def initialize(field_name, attributes = {})
        @field_name = field_name
        attributes.each do |key, value|
          self.send("#{key.to_s}=", value)
        end
      end
    end
  end
end
