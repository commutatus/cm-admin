require_relative 'utils/associations'

module CmAdmin
  module Models
    class Field
      include Utils::Associations

      attr_accessor :field_name, :label, :header, :field_type, :format, :precision, :height,
        :width, :helper_method, :preview, :custom_link, :prefix, :suffix, :tag_class,
        :display_if, :association_name, :association_type, :col_size

      def initialize(field_name, attributes = {})
        @field_name = field_name
        set_default_values
        attributes.each do |key, value|
          self.send("#{key.to_s}=", value)
        end
        self.height = 50 if self.field_type == :image && self.height.nil?
        self.width = 50 if self.field_type == :image && self.width.nil?
        self.display_if = lambda { |arg| return true } if self.display_if.nil?

        validation_for_association
      end

      def set_default_values
        self.precision = 2
        self.tag_class = {}
        self.col_size = nil
        self.field_type = :string
      end
    end
  end
end
