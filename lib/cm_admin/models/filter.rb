require_relative 'utils/helpers'

module CmAdmin
  module Models
    class Filter
      include Utils::Helpers

      attr_accessor :db_column_name, :filter_type, :placeholder, :collection, :filter_with

      VALID_FILTER_TYPES = Set[:date, :multi_select, :range, :search, :single_select].freeze

      def initialize(db_column_name:, filter_type:, options: {})
        raise TypeError, "Can't have array of multiple columns for #{filter_type} filter" if db_column_name.is_a?(Array) && db_column_name.size > 1 && !filter_type.to_sym.eql?(:search)
        raise ArgumentError, "Kindly select a valid filter type like #{VALID_FILTER_TYPES.sort.to_sentence(last_word_connector: ', or ')} instead of #{filter_type} for column #{db_column_name}" unless VALID_FILTER_TYPES.include?(filter_type.to_sym)

        @db_column_name, @filter_type = structure_data(db_column_name, filter_type)
        @filter_with = nil
        set_default_values
        options.each do |key, value|
          send("#{key}=", value)
        end
      end

      def structure_data(db_column_name, filter_type)
        filter_type = filter_type.is_a?(Array) ? filter_type[0].to_sym : filter_type.to_sym

        db_column_name = case filter_type
                         when :search
                           ([] << db_column_name).flatten.map { |x| x.instance_of?(Hash) ? x : x.to_sym }
                         else
                           db_column_name.is_a?(Array) ? db_column_name[0].to_sym : db_column_name.to_sym
                         end
        [db_column_name, filter_type]
      end

      # Set default placeholder for the filter.
      # Date and range filter will not have any placeholder.
      # Else condition is added for fallback.
      def set_default_values
        placeholder = case filter_type
                      when :search
                        'Search'
                      when :single_select, :multi_select
                        "Select/search #{humanized_field_value(db_column_name)}"
                      else
                        "Enter #{humanized_field_value(db_column_name)}"
                      end
        self.placeholder = placeholder
      end

      # Methods to filter the records based on the filter type.
      class << self
        def filtered_data(filter_params, records, filters)
          if filter_params
            filter_params.each do |scope_type, scope_value|
              filter_method = case scope_type
                           when 'date', 'range'
                             'date_and_range'
                           when 'single_select', 'multi_select'
                             'dropdown'
                           else
                             scope_type
                           end
              records = send("cm_#{filter_method}_filter", scope_value, records, filters) if scope_value.present?
            end
          end
          records
        end

        def cm_search_filter(scope_value, records, filters)
          return nil if scope_value.blank?

          table_name = records.table_name
          filters.select { |x| x if x.filter_type.eql?(:search) }.each do |filter|
            if filter.filter_with.present?
              return records.send(filter.filter_with, scope_value)
            else
              query_variables = []
              filter.db_column_name.each do |col|
                case col
                when Symbol
                  query_variables << "#{table_name.pluralize}.#{col}"
                when Hash
                  col.map do |key, value|
                    value.map { |val| query_variables << "#{key.to_s.pluralize}.#{val}" }
                  end
                end
              end
              terms = scope_value.downcase.split(/\s+/)
              terms = terms.map { |e|
                (e.gsub('*', '%').prepend('%') + '%').gsub(/%+/, '%')
              }
              sql = ''
              query_variables.each.with_index do |column, i|
                sql.concat("#{column} ILIKE ?")
                sql.concat(' OR ') unless query_variables.size.eql?(i + 1)
              end

              if filter.db_column_name.map { |x| x.is_a?(Hash) }.include?(true)
                associations_hash = filter.db_column_name.select { |x| x if x.is_a?(Hash) }.last
                records = records.left_joins(associations_hash.keys).distinct
              end

              records = records.where(
                terms.map { |term|
                  sql
                }.join(' AND '),
                *terms.map { |e| [e] * query_variables.size }.flatten
              )
              return records
            end
          end
        end

        def cm_date_and_range_filter(scope_value, records, filters)
          return nil if scope_value.nil?

          scope_value.each do |key, value|
            filters.select { |x| x if [:date, :range].include?(x.filter_type) && x.db_column_name.to_s == key.to_s }.each do |filter|

              next unless value.present?

              value = value.split(' to ')
              from = value[0].presence
              to = value[1].presence
              if filter.filter_with.present?
                records = records.send(filter.filter_with, from, to)
              else
                records = records.where(key => from..to)
              end
            end
          end
          records
        end

        def cm_dropdown_filter(scope_value, records, filters)
          return nil if scope_value.nil?

          scope_value.each do |key, value|
            filters.select { |x| x if [:single_select, :multi_select].include?(x.filter_type) && x.db_column_name.to_s == key.to_s  }.each do |filter|
              if filter.filter_with.present?
                records = records.send(filter.filter_with, value) if value.present?
              else
                records = records.where(key => value) if value.present?
              end
            end
          end
          records
        end
      end
    end
  end
end
