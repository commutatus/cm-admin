module CmAdmin
  module Models
    class CmShowSection

      attr_accessor :section_name, :available_section_fields

      def initialize(section_name, &block)
        @available_section_fields = []
        @section_name = section_name
        instance_eval(&block)
      end

      def field(field_name, options={})
        @available_section_fields << CmAdmin::Models::Field.new(field_name, options)
      end
    end
  end
end