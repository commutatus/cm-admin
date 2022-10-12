module CmAdmin
  module Models
    class Importer

      attr_accessor :class_name, :importer_type

      VALID_IMPORTER_TYPES = [:csv_importer, :custom_importer]

      def initialize(class_name, importer_type=:csv_importer)
        raise ArgumentError, "Kindly select a valid importer type like #{VALID_IMPORTER_TYPES.sort.to_sentence(last_word_connector: ', or ')} instead of #{importer_type}" unless VALID_IMPORTER_TYPES.include?(importer_type.to_sym)
        @class_name = class_name
        @importer_type = importer_type
      end

    end
  end
end
