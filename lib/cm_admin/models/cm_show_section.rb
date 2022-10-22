module CmAdmin
  module Models
    class CmShowSection

      attr_accessor :section_name, :available_section_fields, :display_if

      def initialize(section_name, display_if, &block)
        @available_section_fields = []
        @section_name = section_name
        @display_if = display_if || lambda { |arg| return true }
        instance_eval(&block)
      end

      def field(field_name, options={})
        @available_section_fields << CmAdmin::Models::Field.new(field_name, options)
      end
    end
  end
end