module CmAdmin
  module Models
    class Filter
      attr_accessor :db_column_name, :filter_type, :placeholder, :collection

      VALID_FILTER_TYPES = Set[:date, :multi_select, :range, :search, :single_select].freeze

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
          db_column_name = (Array.new << db_column_name).flatten.map{|x| x.class.eql?(Hash) ? x : x.to_sym}
        else
          db_column_name = db_column_name.is_a?(Array) ? db_column_name[0].to_sym : db_column_name.to_sym
        end
        [db_column_name, filter_type]
      end

      # Methods to filter the records based on the filter type.
      class << self
        def filtered_data(filter_params, records, filters)
          if filter_params
            filter_params.each do |scope_type, scope_value|
              scope_name = if scope_type.eql?('date') || scope_type.eql?('range')
                'date_and_range'
              elsif scope_type.eql?('single_select') || scope_type.eql?('multi_select')
                'dropdown'
              else
                scope_type
              end
              records = self.send("cm_#{scope_name}_filter", scope_value, records, filters) if scope_value.present?
            end
          end
          records
        end

        def cm_search_filter(scope_value, records, filters)
          return nil if scope_value.blank?
          table_name = records.table_name
          filters.select{|x| x if x.filter_type.eql?(:search)}.each do |filter|
            query_variables = []
            filter.db_column_name.each do |col|
              if col.is_a?(Symbol)
                query_variables << "#{table_name.pluralize}.#{col}"
              elsif col.is_a?(Hash)
                col.map do |key, value|
                  value.map {|val| query_variables << "#{key.to_s.pluralize}.#{val}" }
                end
              end
            end
            terms = scope_value.downcase.split(/\s+/)
            terms = terms.map { |e|
              (e.gsub('*', '%').prepend('%') + '%').gsub(/%+/, '%')
            }
            sql = ""
            query_variables.each.with_index do |column, i|
              sql.concat("#{column} ILIKE ?")
              sql.concat(' OR ') unless query_variables.size.eql?(i+1)
            end

            if filter.db_column_name.map{|x| x.is_a?(Hash)}.include?(true)
              associations_hash = filter.db_column_name.select{|x| x if x.is_a?(Hash)}.last
              records = records.left_joins(associations_hash.keys).distinct
            end

            records = records.where(
              terms.map { |term|
                sql
              }.join(' AND '),
              *terms.map { |e| [e] * query_variables.size }.flatten
            )
          end
          records
        end

        def cm_date_and_range_filter(scope_value, records, filters)
          return nil if scope_value.nil?
          scope_value.each do |key, value|
            if value.present?
              value = value.split(' to ')
              from = value[0].presence
              to = value[1].presence
              records = records.where(key => from..to)
            end
          end
          records
        end

        def cm_dropdown_filter(scope_value, records, filters)
          return nil if scope_value.nil?
          scope_value.each do |key, value|
            records = records.where(key => value) if value.present?
          end
          records
        end
      end
    end
  end
end
