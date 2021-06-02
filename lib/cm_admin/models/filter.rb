module CmAdmin
  module Models
    class Filter
      attr_accessor :db_column_name, :filter_type, :placeholder, :collection, :multiselect, :checked

      VALID_FILTER_TYPES = [:search, :date, :range, :dropdown, :checkbox].freeze

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
