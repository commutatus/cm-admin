module CmAdmin
  module Models
    class Filter
      attr_accessor :db_column_name, :filter_type, :placeholder, :collection, :multiselect, :checked

      VALID_FILTER_TYPES = Set[:checkbox, :date, :dropdown, :range, :search].freeze

      def initialize(db_column_name:, filter_type:, options: {})
        raise TypeError, "Can't have array of multiple columns for #{filter_type} filter" if db_column_name.is_a?(Array) && db_column_name.size > 1 && !filter_type.to_sym.eql?(:search)
        raise ArgumentError, "Kindly select a valid filter type like #{VALID_FILTER_TYPES.sort.to_sentence(last_word_connector: ', or ')} instead of #{filter_type} for column #{db_column_name}" unless VALID_FILTER_TYPES.include?(filter_type.to_sym)
        @db_column_name, @filter_type = structure_data(db_column_name, filter_type)
        options.each do |key, value|
          self.send("#{key.to_s}=", value)
        end
      end

      def structure_data(db_column_name, filter_type)
        filter_type = filter_type.is_a?(Array) ? filter_type[0].to_sym : filter_type.to_sym

        case filter_type
        when :search
          db_column_name = (Array.new << db_column_name).flatten.map(&:to_sym)
        else
          db_column_name = db_column_name.is_a?(Array) ? db_column_name[0].to_sym : db_column_name.to_sym
        end
        [db_column_name, filter_type]
      end
    end
  end
end
