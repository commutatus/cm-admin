module CmAdmin
  module Models
    class Section
      # Description
      # A section is like a container which holds a list of fields or form fields
      # These list of fields are iterated and displayed on show/new/edit page.
      # It also contains rows, which contains sections and fields.

      attr_accessor :section_name, :section_fields, :display_if, :current_action, :cm_model, :parent_section,
                    :nested_table_fields, :rows, :col_size, :current_nested_field, :nested_section, :html_attrs

      def initialize(section_name, current_action, cm_model, display_if, html_attrs, col_size, &block)
        @section_fields = []
        @rows = []
        @nested_table_fields = []
        @col_size = col_size
        @section_name = section_name
        @current_action = current_action
        @cm_model = cm_model
        @html_attrs = html_attrs || {}
        @display_if = display_if || ->(arg) { true }
        @current_nested_field = nil
        @nested_section = nil
        @parent_section = nil
        instance_eval(&block)
      end

      def field(field_name, options = {})
        if @current_nested_field
          @current_nested_field.fields << CmAdmin::Models::Field.new(field_name, options)
        else
          @section_fields << CmAdmin::Models::Field.new(field_name, options)
        end
      end

      def form_field(field_name, options = {}, arg = nil)
        if @current_nested_field
          @current_nested_field.fields << CmAdmin::Models::FormField.new(field_name, options[:input_type], options)
        else
          @section_fields << CmAdmin::Models::FormField.new(field_name, options[:input_type], options)
        end
      end

      def nested_form_field(field_name, options = {}, &block)
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

      def row(display_if: nil, html_attrs: nil, &block)
        @rows ||= []
        @rows << CmAdmin::Models::Row.new(@current_action, @model, display_if, html_attrs, &block)
      end

      def nested_form_section(section_name, display_if: nil, col_size: nil, html_attrs: nil, &block)
        @nested_section = CmAdmin::Models::Section.new(section_name, @current_action, @cm_model, display_if, html_attrs, col_size, &block)
        @nested_section.parent_section = self
      end
    end
  end
end
