module CmAdmin
  module Models
    module DslMethod
      extend ActiveSupport::Concern

      def cm_index(page_title: nil ,page_description: nil, &block)
        @current_action = CmAdmin::Models::Action.find_by(self, name: 'index')
        @current_action.page_title = page_title
        @current_action.page_description = page_description
        yield
        # action.instance_eval(&block)
      end

      def cm_show(page_title: nil,page_description: nil,&block)
        @current_action = CmAdmin::Models::Action.find_by(self, name: 'show')
        @current_action.page_title = page_title
        @current_action.page_description = page_description
        yield
      end
  
      def cm_edit(page_title: nil,page_description: nil, &block)
        @current_action = CmAdmin::Models::Action.find_by(self, name: 'edit')
        @current_action.page_title = page_title
        @current_action.page_description = page_description
        yield
      end
  
      def cm_new(page_title: nil,page_description: nil,&block)
        @current_action = CmAdmin::Models::Action.find_by(self, name: 'new')
        @current_action.page_title = page_title
        @current_action.page_description = page_description
        yield
      end

      def page_title(title)
        if @current_action
          @current_action.page_title = title
        end
      end
  
      def page_description(description)
        if @current_action
          @current_action.page_description = description
        end
      end
  
      def tab(tab_name, custom_action, associated_model: nil, layout_type: nil, layout: nil, partial: nil, &block)
        if custom_action.to_s == ''
          @current_action = CmAdmin::Models::Action.find_by(self, name: 'show')
          @available_tabs << CmAdmin::Models::Tab.new(tab_name, '', &block)
        else
          action = CmAdmin::Models::Action.new(name: custom_action.to_s, verb: :get, path: ':id/'+custom_action, layout_type: layout_type, layout: layout, partial: partial, child_records: associated_model)
          @available_actions << action
          @current_action = action
          @available_tabs << CmAdmin::Models::Tab.new(tab_name, custom_action, &block)
        end
        yield if block
      end
  
      def cm_show_section(section_name, &block)
        @available_fields[@current_action.name.to_sym] ||= []
        @available_fields[@current_action.name.to_sym] << CmAdmin::Models::CmShowSection.new(section_name, &block)
      end
  
      def form_field(field_name, options={}, arg=nil)
        unless @current_action.is_nested_field
          @available_fields[@current_action.name.to_sym][:fields] << CmAdmin::Models::FormField.new(field_name, options[:input_type], options)
        else
          @available_fields[@current_action.name.to_sym][@current_action.nested_table_name] ||= []
          @available_fields[@current_action.name.to_sym][@current_action.nested_table_name] << CmAdmin::Models::FormField.new(field_name, options[:input_type], options)
        end
      end
  
      def nested_form_field(field_name, &block)
        @current_action.is_nested_field = true
        @current_action.nested_table_name = field_name
        yield
      end
  
      def column(field_name, options={})
        @available_fields[@current_action.name.to_sym] ||= []
        if @available_fields[@current_action.name.to_sym].select{|x| x.lockable}.size > 0 && options[:lockable]
          raise "Only one column can be locked in a table."
        end
        unless @available_fields[@current_action.name.to_sym].map{|x| x.field_name.to_sym}.include?(field_name)
          @available_fields[@current_action.name.to_sym] << CmAdmin::Models::Column.new(field_name, options)
        end
      end
  
      def all_db_columns(options={})
        field_names = self.instance_variable_get(:@ar_model)&.columns&.map{|x| x.name.to_sym}
        if options.include?(:exclude) && field_names
          excluded_fields = (Array.new << options[:exclude]).flatten.map(&:to_sym)
          field_names -= excluded_fields
        end
        field_names.each do |field_name|
          column field_name
        end
      end

      # Custom actions
      # eg
      # class User < ApplicationRecord
      #   cm_admin do
      #     custom_action name: 'submit', verb: 'post', path: ':id/submit' do
      #       def user_submit
      #         Code for action here...
      #       end
      #     end
      #   end
      # end
      def custom_action(name: nil, verb: nil, layout: nil, partial: nil, path: nil, &block)
        @available_actions << CmAdmin::Models::Action.new(name: name, verb: verb, layout: layout, partial: partial, path: path)
        self.class.class_eval(&block)
      end

      def filter(db_column_name, filter_type, options={})
        @filters << CmAdmin::Models::Filter.new(db_column_name: db_column_name, filter_type: filter_type, options: options)
      end
    end
  end
end