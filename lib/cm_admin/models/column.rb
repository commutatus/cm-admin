require_relative 'utils/associations'

module CmAdmin
  module Models
    class Column
      include Utils::Associations

      attr_accessor :field_name, :field_type, :header, :format, :prefix, :suffix, :exportable, :round, :height, :width,
      :cm_css_class, :link, :url, :custom_method, :helper_method, :managable, :lockable, :drawer_partial, :tag_class,
      :display_if, :association_name, :association_type, :viewable, :custom_link

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
                       elsif self.field_type.to_s == 'association'
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
        self.viewable = true
        self.tag_class = {}
        self.field_type = :string
      end

      class << self
        def find_by(model, action_name, search_hash)
          model.available_fields[action_name].find { |column| column.field_name == search_hash[:name] }
        end
      end
    end
  end
end
