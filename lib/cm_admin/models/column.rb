module CmAdmin
  module Models
    class Column
      attr_accessor :field_name, :field_type, :header, :format, :prefix, :suffix, :exportable, :round,
      :cm_css_class, :link, :url, :custom_method, :helper_method

      def initialize(field_name, attributes = {})
        @field_name = field_name
        attributes.each do |key, value|
          self.send("#{key.to_s}=", value)
        end

        #formatting header (either field_name or value present in header attribute)
        self.send("header=", format_header)

        #all columns are exportable by default
        @exportable = true if attributes[:exportable].nil?
      end

      #returns a string value as a header (either field_name or value present in header attribute)
      def format_header
        self.header.present? ? self.header.to_s.gsub(/_/, ' ')&.upcase : self.field_name.to_s.gsub(/_/, ' ').upcase
      end

      #formatting value for different data types
      def self.format_data_type(column, value)
        case column.column_type
        when :string
          if column.format.present?
            column.format = [column.format] if column.format.is_a? String
            column.format.each do |formatter|
              value = value.send(formatter)
            end
          end
        when :datetime
          format_value = column.format.present? ? column.format.to_s : '%d/%m/%Y'
          value = value.strftime(format_value)
        when :enum
          value = value.titleize
        when :decimal
          round_to = column.round.present? ? column.round.to_i : 2
          value = value.round(round_to)
        when :custom

        end
        return value
      end

      class << self
        def find_by(model, search_hash)
          model.available_fields.find { |i| i.name == search_hash[:name] }
        end
      end

    end
  end
end
