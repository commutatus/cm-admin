module CmAdmin
  module Models
    class Export
      class << self
        def generate_excel(klass_name, columns = [], file_path)
          klass = klass_name.constantize
          records = get_records(klass, columns)
          file_path = "#{Rails.root}/tmp/Test_data_#{DateTime.now.strftime("%Y-%m-%d_%H-%M-%S")}.xlsx"
          create_excel(records, columns, file_path)
          return file_path
        end

        def get_records(klass, columns)
          records = klass
          deserialized_columns = CmAdmin::Utils.deserialize_csv_columns(columns, :as_json_params)
          # This includes isn't recursve, a full solution should be recursive
          records.includes(deserialized_columns[:include].keys).find_each.as_json(deserialized_columns)
        end

        def create_excel(records, class_name, file_path)
          flattened_records = records.map { |record| CmAdmin::Utils.flatten_hash(record) }
          columns = flattened_records.map{|x| x.keys}.flatten.uniq.sort
          size_arr = []
          columns.size.times { size_arr << 22 }
          xl = Axlsx::Package.new
          xl.workbook.add_worksheet do |sheet|
            sheet.add_row columns&.map(&:titleize), b: true
            flattened_records.each do |record|
              sheet.add_row(columns.map { |column| record[column] })
            end
          sheet.column_widths(*size_arr)
          end
          xl.serialize(file_path)
        end
      end
    end
  end
end
