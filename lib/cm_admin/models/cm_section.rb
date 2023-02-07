module CmAdmin
  module Models
    class CmSection

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

      def form_field(field_name, options={}, arg=nil)
        # unless @current_action.is_nested_field
        #   @available_fields[@current_action.name.to_sym][:fields] << CmAdmin::Models::FormField.new(field_name, options[:input_type], options)
        # else
        #   @available_fields[@current_action.name.to_sym][@current_action.nested_table_name] ||= []
        #   @available_fields[@current_action.name.to_sym][@current_action.nested_table_name] << CmAdmin::Models::FormField.new(field_name, options[:input_type], options)
        # end
      end

      def nested_form_field(field_name, &block)
        # @current_action.is_nested_field = true
        # @current_action.nested_table_name = field_name
        yield
      end
      
    end
  end
end