module CmAdmin
  module Models
    class Importer

      attr_accessor :class_name

      def initialize(class_name)
        @class_name = class_name
      end

    end
  end
end
