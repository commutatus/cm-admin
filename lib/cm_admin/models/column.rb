module CmAdmin
  module Models
    class Column
      attr_accessor :db_column_name, :column_type, :header, :format, :prefix, :exportable

      def initialize(db_column_name, attributes = {})
        @db_column_name = db_column_name
        attributes.each do |key, value|
          self.send("#{key.to_s}=", value)
        end
        @exportable = true if attributes[:exportable].nil?
      end

    end
  end
end
