module CmAdmin
  module Models
    class Field

      attr_accessor :field_name, :label, :header, :field_type, :format, :precision, :height,
        :width, :helper_method, :preview, :custom_link, :prefix, :suffix, :tag_class,
        :display_if, :association_name, :association_type

      def initialize(field_name, attributes = {})
        @field_name = field_name
        set_default_values
        attributes.each do |key, value|
          self.send("#{key.to_s}=", value)
        end
        self.height = 50 if self.field_type == :image && self.height.nil?
        self.width = 50 if self.field_type == :image && self.width.nil?
        self.display_if = lambda { |arg| return true } if self.display_if.nil?
      end

      def set_default_values
        self.tag_class = {}
      end
    end
  end
end
