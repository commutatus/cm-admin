module CmAdmin
  module Models
    class Importer

      attr_accessor :class_name, :importer_type

      def initialize(class_name, importer_type='csv_importer')
        @class_name = class_name
        @importer_type = importer_type
      end

    end
  end
end
