module CmAdmin
  module Models
    class Section

      attr_accessor :section_name, :section_fields, :display_if, :current_action, :cm_model, :nested_table_fields

      def initialize(section_name, current_action, cm_model, display_if, &block)
        @section_fields = []
        @nested_table_fields = {}
        @section_name = section_name
        @current_action = current_action
        @cm_model = cm_model
        @display_if = display_if || lambda { |arg| return true }
        instance_eval(&block)
      end

      def field(field_name, options={})
        @section_fields << CmAdmin::Models::Field.new(field_name, options)
      end

      def form_field(field_name, options={}, arg=nil)
        if @current_action.is_nested_field
          @nested_table_fields[@current_action.nested_table_name] ||= []
          @nested_table_fields[@current_action.nested_table_name] << CmAdmin::Models::FormField.new(field_name, options[:input_type], options)
        else
          @section_fields << CmAdmin::Models::FormField.new(field_name, options[:input_type], options)
        end
      end

      def nested_form_field(field_name, &block)
        @current_action.is_nested_field = true
        @current_action.nested_table_name = field_name
        yield
      end

    end
  end
end