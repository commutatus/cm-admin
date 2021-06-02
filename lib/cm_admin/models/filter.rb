module CmAdmin
  module Models
    class Filter
      def initialize(db_column_name:, filter_type:, options: {})
        @name = db_column_name
        @type = filter_type.to_sym
        options.each do |key, value|
          self.send("#{key.to_s}=", value)
        end
      end
    end
  end
end
