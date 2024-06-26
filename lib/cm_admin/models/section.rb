module CmAdmin
  module Models
    class Section

      # Description
      # A section is like a container which holds a list of fields or form fields
      # These list of fields are iterated and displayed on show/new/edit page.
      # It also contains rows, which contains sections and fields.

      attr_accessor :section_name, :section_fields, :display_if, :current_action, :cm_model, :nested_table_fields, :rows, :col_size, :current_nested_field

      def initialize(section_name, current_action, cm_model, display_if, col_size, &block)
        @section_fields = []
        @rows = []
        @nested_table_fields = []
        @col_size = col_size
        @section_name = section_name
        @current_action = current_action
        @cm_model = cm_model
        @display_if = display_if || lambda { |arg| return true }
        @current_nested_field = nil
        instance_eval(&block)
      end

      def field(field_name, options={})
        if @current_nested_field
          @current_nested_field.fields << CmAdmin::Models::Field.new(field_name, options)
        else
          @section_fields << CmAdmin::Models::Field.new(field_name, options)
        end
      end

      def form_field(field_name, options={}, arg=nil)
        if @current_nested_field
          @current_nested_field.fields << CmAdmin::Models::FormField.new(field_name, options[:input_type], options)
        else
          @section_fields << CmAdmin::Models::FormField.new(field_name, options[:input_type], options)
        end
      end

      def nested_form_field(field_name, options={}, &block)
        # @current_action.is_nested_field = true
        # @current_action.nested_table_name = field_name
        nested_field = CmAdmin::Models::NestedField.new(field_name, options)
        if nested_field.parent_field
          @current_nested_field.associated_fields << nested_field
        else
          @nested_table_fields << nested_field
        end
        @current_nested_field = nested_field
        yield
      end

      def row(display_if: nil, &block)
        @rows ||= []
        @rows << CmAdmin::Models::Row.new(@current_action, @model, display_if, &block)
      end

    end
  end
end