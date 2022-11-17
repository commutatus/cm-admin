module CmAdmin
  module Models
    class Column
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

        return unless association_type.present?

        if association_type.to_s == 'polymorphic'
          raise ArgumentError.new 'Expected field_name to be Array' unless field_name.class.to_s == "Array"

          field_name.each do |element|
            raise ArgumentError.new "Expected element #{element} of field_name Array to be Hash" unless element.class.to_s == "Hash"
          end
        elsif ['belongs_to', 'has_one'].include? association_type.to_s && field_name.class.to_s != "Symbol" && field_name.class.to_s != "String"
          raise ArgumentError.new 'Expected field_name to be String or Symbol'
        end
      end

      #returns a string value as a header (either field_name or value present in header attribute)
      def format_header
        if self.header.present?
          self.header.to_s.titleize&.upcase
        elsif self.association_type.to_s == "polymorphic"
          self.association_name.to_s.titleize.upcase
        else
          self.field_name.to_s.titleize.upcase
        end
      end

      def set_default_values
        self.exportable = true
        self.managable = true
        self.lockable = false
        self.tag_class = {}
      end

      class << self
        def find_by(model, search_hash)
          model.available_fields.find { |i| i.name == search_hash[:name] }
        end
      end

    end
  end
end
