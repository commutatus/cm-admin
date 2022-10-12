module CmAdmin
  module Models
    class Field

      attr_accessor :field_name, :label, :header, :field_type, :format, :precision, :height,
        :width, :helper_method, :preview, :custom_link, :precision, :prefix, :suffix, :tag_class

      def initialize(field_name, attributes = {})
        @field_name = field_name
        set_default_values
        attributes.each do |key, value|
          self.send("#{key.to_s}=", value)
        end
      end

      def set_default_values
        self.tag_class = {}
        self.height = 50
        self.width = 50
      end
    end
  end
end
