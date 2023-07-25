module CmAdmin
  module Models
    class Export
      class << self
        def generate_excel(klass_name, params, helpers)
          klass = klass_name.constantize
          selected_column_names = params[:columns] || []
          # filter_params = params[:filters]
          model = CmAdmin::Model.find_by({name: klass_name})
          # records = get_records(klass, model, columns, helpers)
          records = "CmAdmin::#{klass_name}Policy::Scope".constantize.new(Current.user, klass).resolve
          filtered_data = CmAdmin::Models::Filter.filtered_data(model.filter_params(params), records, model.filters)
          formatted_data = format_records(filtered_data, model, selected_column_names, helpers)
          file_path = "#{Rails.root}/tmp/#{klass}_data_#{DateTime.now.strftime("%Y-%m-%d_%H-%M-%S")}.xlsx"
          create_workbook(model, formatted_data, selected_column_names, file_path)
          return file_path
        end

        def format_records(records, model, selected_column_names, helpers)
          deserialized_columns = CmAdmin::Utils.deserialize_csv_columns(selected_column_names, :as_json_params)
          # This includes isn't recursve, a full solution should be recursive
          records_arr = []
          records.includes(deserialized_columns[:include].keys).find_each do |record|
            record_hash = record.as_json({ only: selected_column_names.map(&:to_sym) })
            selected_column_names.each do |column_name|
              break unless model.available_fields[:index].map(&:field_name).include?(column_name.to_sym)

              column = CmAdmin::Models::Column.find_by(model, :index, { name: column_name.to_sym })
              if column.field_type == :custom
                record_hash[column.field_name] = helpers.send(column.helper_method, record, column.field_name).to_s
              else
                record_hash[column.field_name] = record.send(column.field_name).to_s
              end
            end
            records_arr << record_hash
          end
          records_arr
        end

        def create_workbook(cm_model, records, _class_name, file_path)
          flattened_records = records.map { |record| CmAdmin::Utils.flatten_hash(record) }
          # columns = flattened_records.map{|x| x.keys}.flatten.uniq.sort
          columns = exportable_columns(cm_model).select { |column| flattened_records.first.keys.include?(column.field_name.to_s) }
          size_arr = []
          columns.size.times { size_arr << 22 }
          xl = Axlsx::Package.new
          xl.workbook.add_worksheet do |sheet|
            sheet.add_row columns&.map(&:header), b: true
            flattened_records.each do |record|
              sheet.add_row(columns.map { |column| record[column.field_name.to_s] })
            end
            sheet.column_widths(*size_arr)
          end
          xl.serialize(file_path)
        end

        def exportable_columns(klass)
          klass.available_fields[:index].select(&:exportable)
        end

      end
    end
  end
end
