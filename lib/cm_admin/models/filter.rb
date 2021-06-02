module CmAdmin
  module Models
    class Filter
      attr_accessor :db_column_name, :filter_type, :placeholder, :collection, :multiselect, :checked

      VALID_FILTER_TYPES = [:search, :date, :range, :dropdown, :checkbox].freeze

      def initialize(db_column_name:, filter_type:, options: {})
        raise ArgumentError, "Kindly select a valid filter type like #{VALID_FILTER_TYPES.to_sentence} instead of #{filter_type} for column #{db_column_name}" unless VALID_FILTER_TYPES.include?(filter_type.to_sym)
        @name = db_column_name
        @type = filter_type.to_sym
        options.each do |key, value|
          self.send("#{key.to_s}=", value)
        end
      end
    end
  end
end
