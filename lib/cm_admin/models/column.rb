require_relative 'utils/associations'

module CmAdmin
  module Models
    class Column
      include Utils::Associations

      attr_accessor :field_name, :field_type, :header, :format, :prefix, :suffix, :exportable, :round, :height, :width,
      :cm_css_class, :link, :url, :custom_method, :helper_method, :managable, :lockable, :drawer_partial, :tag_class,
      :display_if, :association_name, :association_type

      def initialize(field_name, attributes = {})
        @field_name = field_name
        set_default_values
        attributes.each do |key, value|
          self.send("#{key.to_s}=", value)
        end

        #formatting header (either field_name or value present in header attribute)
        self.send("header=", format_header)
        self.height = 50 if self.field_type == :image && self.height.nil?
        self.width = 50 if self.field_type == :image && self.width.nil?
        self.display_if = lambda { |arg| return true } if self.display_if.nil?

        validation_for_association
      end

      #returns a string value as a header (either field_name or value present in header attribute)
      def format_header
        header_value = if self.header.present?
                         self.header
                       elsif self.association_type.to_s == "polymorphic"
                         self.association_name
                       else
                         self.field_name
                       end
        header_value.to_s.titleize.upcase
      end

      def set_default_values
        self.exportable = true
        self.managable = true
        self.lockable = false
        self.tag_class = {}
      end

      # def validation_for_association
      #   return unless field_type.to_s == "association"

      #   raise ArgumentError, 'Expected association_name and association_type to be present' if association_name.nil? || association_type.nil?

      #   if association_type.to_s == 'polymorphic'
      #     raise ArgumentError, "Expected field_name - #{field_name} - to be an array of hash. Eg, [{table_name_1: 'column_name_1'}, {table_name_2: 'column_name_2'}]" unless field_name.is_a?(Array)

      #     field_name.each do |element|
      #       raise ArgumentError, "Expected element #{element} to be a hash. Eg, [{table_name_1: 'column_name_1'}, {table_name_2: 'column_name_2'}]" unless element.is_a?(Hash)
      #     end
      #   elsif ['belongs_to', 'has_one'].include? association_type.to_s
      #     raise ArgumentError, "Expected field_name - #{field_name} to be a String or Symbol" unless field_name.is_a?(Symbol) || field_name.is_a?(String)
      #   end
      # end

      class << self
        def find_by(model, search_hash)
          model.available_fields.find { |i| i.name == search_hash[:name] }
        end
      end
    end
  end
end
