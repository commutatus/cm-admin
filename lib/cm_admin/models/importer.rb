module CmAdmin
  module Models
    class Importer

      attr_accessor :class_name, :importer_type, :sample_file_path

      VALID_IMPORTER_TYPES = [:csv_importer, :custom_importer]

      def initialize(class_name, importer_type=:csv_importer, sample_file_path=nil)
        raise ArgumentError, "Kindly select a valid importer type like #{VALID_IMPORTER_TYPES.sort.to_sentence(last_word_connector: ', or ')} instead of #{importer_type}" unless VALID_IMPORTER_TYPES.include?(importer_type.to_sym)
        @class_name = class_name
        @importer_type = importer_type
        @sample_file_path = sample_file_path
      end

    end
  end
end
