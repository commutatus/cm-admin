module CmAdmin
  module Models
    class Filter
      attr_accessor :db_column_name, :filter_type, :placeholder, :collection, :multiselect, :checked

      VALID_FILTER_TYPES = Set[:checkbox, :date, :dropdown, :range, :search].freeze

      def initialize(db_column_name:, filter_type:, options: {})
        raise TypeError, "Can't have array of multiple columns for #{filter_type} filter" if db_column_name.is_a?(Array) && db_column_name.size > 1 && !filter_type.to_sym.eql?(:search)
        raise ArgumentError, "Kindly select a valid filter type like #{VALID_FILTER_TYPES.sort.to_sentence(last_word_connector: ', or ')} instead of #{filter_type} for column #{db_column_name}" unless VALID_FILTER_TYPES.include?(filter_type.to_sym)
        @db_column_name = db_column_name
        @filter_type = filter_type.to_sym
        options.each do |key, value|
          self.send("#{key.to_s}=", value)
        end
      end
    end
  end
end
