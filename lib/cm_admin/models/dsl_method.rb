module CmAdmin
  module Models
    module DslMethod
      extend ActiveSupport::Concern

      def cm_page(name: nil, partial: nil, path: nil, route_type: nil, page_title: nil, display_type: :button, &block)
        action = CmAdmin::Models::CustomAction.new(name: name, verb: :get, partial: partial, path: path, route_type: route_type, display_type: display_type, &block)
        @available_actions << action
        # @available_actions << CmAdmin::Models::CustomAction.new(name: name, verb: 'get', layout: 'cm_admin', partial: partial, path: path, parent: self.current_action.name, route_type: route_type, page_title: page_title, display_type: display_type, &block)
        # @current_action = CmAdmin::Models::CustomAction.find_by(self, name: name)
      end

      def cm_index(page_title: nil, page_description: nil, partial: nil, &block)
        @current_action = CmAdmin::Models::Action.find_by(self, name: 'index')
        @current_action.set_values(page_title, page_description, partial)
        yield
        # action.instance_eval(&block)
      end

      def cm_show(page_title: nil, page_description: nil, partial: nil, &block)
        @current_action = CmAdmin::Models::Action.find_by(self, name: 'show')
        @current_action.set_values(page_title, page_description, partial)
        yield
      end

      def cm_edit(page_title: nil,page_description: nil, partial: nil, &block)
        @current_action = CmAdmin::Models::Action.find_by(self, name: 'edit')
        @current_action.set_values(page_title, page_description, partial)
        yield
      end

      def cm_new(page_title: nil,page_description: nil, partial: nil, &block)
        @current_action = CmAdmin::Models::Action.find_by(self, name: 'new')
        @current_action.set_values(page_title, page_description, partial)
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
          action = CmAdmin::Models::Action.new(name: custom_action.to_s, verb: :get, path: ':id/'+custom_action,
                      layout_type: layout_type, layout: layout, partial: partial, child_records: associated_model,
                      action_type: :custom, display_type: :page)
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
      def custom_action(name: nil, verb: nil, layout: nil, layout_type: nil, partial: nil, path: nil, display_type: nil, display_if: lambda { |arg| return true }, route_type: nil, &block)
        action = CmAdmin::Models::CustomAction.new(
                    name: name, verb: verb, layout: layout, layout_type: layout_type, partial: partial, path: path,
                    parent: self.current_action.name, display_type: display_type, display_if: display_if,
                    action_type: :custom, route_type: route_type, &block)
        @available_actions << action
        # self.class.class_eval(&block)
      end

      def filter(db_column_name, filter_type, options={})
        @filters << CmAdmin::Models::Filter.new(db_column_name: db_column_name, filter_type: filter_type, options: options)
      end

      def sort_direction(direction = :desc)
        raise ArgumentError, "Select a valid sort direction like #{CmAdmin::Models::Action::VALID_SORT_DIRECTION.join(' or ')} instead of #{direction}" unless CmAdmin::Models::Action::VALID_SORT_DIRECTION.include?(direction.to_sym.downcase)

        @current_action.sort_direction = direction.to_sym if @current_action
      end

      def sort_column(column = :created_at)
        model = if @current_action.child_records
          CmAdmin::Model.find_by(name: @current_action.child_records.to_s.classify)
        else
          self
        end
        db_columns = model.instance_variable_get(:@ar_model)&.columns&.map{|x| x.name.to_sym}
        raise "Sorting for custom column #{column} does not exist." unless db_columns.include?(column.to_sym)

        @current_action.sort_column = column.to_sym if @current_action
      end
    end
  end
end
