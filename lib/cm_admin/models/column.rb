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

      #return a string value as a header (either db_column_name or value present in header attribute)
      def format_header
        self.header.present? ? self.header.to_s.gsub(/_/, ' ')&.upcase : self.db_column_name.to_s.gsub(/_/, ' ').upcase
      end

    end
  end
end
