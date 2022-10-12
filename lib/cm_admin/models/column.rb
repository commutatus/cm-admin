module CmAdmin
  module Models
    class Column
      attr_accessor :field_name, :field_type, :header, :format, :prefix, :suffix, :exportable, :round, :height, :width,
      :cm_css_class, :link, :url, :custom_method, :helper_method, :managable, :lockable, :drawer_partial, :tag_class

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
      end

      #returns a string value as a header (either field_name or value present in header attribute)
      def format_header
        self.header.present? ? self.header.to_s.gsub(/_/, ' ')&.upcase : self.field_name.to_s.gsub(/_/, ' ').upcase
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
