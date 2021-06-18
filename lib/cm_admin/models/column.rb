module CmAdmin
  module Models
    class Column
      attr_accessor :db_column_name, :column_type, :header, :format, :prefix, :suffix, :exportable, :round

      def initialize(db_column_name, attributes = {})
        @db_column_name = db_column_name
        attributes.each do |key, value|
          self.send("#{key.to_s}=", value)
        end

        #formatting header (either db_column_name or value present in header attribute)
        self.send("header=", format_header)

        #all columns are exportable by default
        @exportable = true if attributes[:exportable].nil?
      end

      #returns a string value as a header (either db_column_name or value present in header attribute)
      def format_header
        self.header.present? ? self.header.to_s.gsub(/_/, ' ')&.upcase : self.db_column_name.to_s.gsub(/_/, ' ').upcase
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
        end
        return value
      end

    end
  end
end
