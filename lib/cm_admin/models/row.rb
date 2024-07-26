module CmAdmin
  module Models
    class Row
      # Description
      # A row is like a container which holds a list of form_field or section.
      # These list of fields or section are iterated and displayed on new/edit page.
      # A row is like a wrapper on the HTML, which adds a div element 'row' class from bootstrap.

      attr_accessor :sections, :display_if, :row_fields, :html_attrs

      def initialize(current_action, cm_model, display_if, html_attrs, &block)
        @sections = []
        @row_fields = []
        @display_if = display_if || ->(arg) { true }
        @html_attrs = html_attrs || {}
        @current_action = current_action
        @cm_model = cm_model
        instance_eval(&block)
      end

      def form_field(field_name, options = {}, arg = nil)
        if @current_action.is_nested_field
          @nested_table_fields[@current_action.nested_table_name] ||= []
          @nested_table_fields[@current_action.nested_table_name] << CmAdmin::Models::FormField.new(field_name, options[:input_type], options)
        else
          @row_fields << CmAdmin::Models::FormField.new(field_name, options[:input_type], options)
        end
      end

      def field(field_name, options = {})
        if @current_nested_field
          @current_nested_field.fields << CmAdmin::Models::Field.new(field_name, options)
        else
          @row_fields << CmAdmin::Models::Field.new(field_name, options)
        end
      end

      def cm_section(section_name, col_size: nil, display_if: nil, html_attrs: nil, &block)
        @sections << CmAdmin::Models::Section.new(section_name, @current_action, @model, display_if, html_attrs, col_size, &block)
      end

      # This method is deprecated. Use cm_section instead.
      def cm_show_section(section_name, col_size: nil, display_if: nil, html_attrs: nil, &block)
        cm_section(section_name, col_size: col_size, display_if: display_if, html_attrs: html_attrs, &block)
      end

      def nested_form_section(section_name, display_if: nil, col_size: nil, html_attrs: nil, &block)
        nested_section = CmAdmin::Models::Section.new(section_name, @current_action, @cm_model, display_if, html_attrs, col_size, &block)
        nested_section.parent_section = self
        @row_fields << nested_section
      end
    end
  end
end
