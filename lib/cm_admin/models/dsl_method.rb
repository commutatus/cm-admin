module CmAdmin
  module Models
    module DslMethod
      extend ActiveSupport::Concern

      def cm_index(page_title: nil, page_description: nil, partial: nil, view_type: :table, &block)
        @current_action = CmAdmin::Models::Action.find_by(self, name: 'index')
        @current_action.set_values(page_title, page_description, partial, view_type)
        yield
      end

      def cm_show(page_title: nil, page_description: nil, partial: nil, &block)
        @current_action = CmAdmin::Models::Action.find_by(self, name: 'show')
        @current_action.set_values(page_title, page_description, partial)
        yield
      end

      def cm_edit(page_title: nil, page_description: nil, partial: nil, redirect_to: nil, &block)
        @current_action = CmAdmin::Models::Action.find_by(self, name: 'edit')
        @current_action.set_values(page_title, page_description, partial, redirect_to)
        yield
      end

      def cm_new(page_title: nil, page_description: nil, partial: nil, redirect_to: nil, &block)
        @current_action = CmAdmin::Models::Action.find_by(self, name: 'new')
        @current_action.set_values(page_title, page_description, partial, redirect_to)
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

      def kanban_view(column_name, exclude: [], only: [])
        if @current_action
          @current_action.kanban_attr[:column_name] = column_name
          @current_action.kanban_attr[:exclude] = exclude
          @current_action.kanban_attr[:only] = only
        end

      end

      def scope_list(scopes=[])
        return unless @current_action

        @current_action.scopes = scopes
      end

      def tab(tab_name, custom_action, associated_model: nil, layout_type: nil, layout: nil, partial: nil, display_if: nil, &block)
        if custom_action.to_s == ''
          @current_action = CmAdmin::Models::Action.find_by(self, name: 'show')
          @available_tabs << CmAdmin::Models::Tab.new(tab_name, '', display_if, &block)
        else
          action = CmAdmin::Models::Action.new(name: custom_action.to_s, verb: :get, path: ':id/'+custom_action,
                      layout_type: layout_type, layout: layout, partial: partial, child_records: associated_model,
                      action_type: :custom, display_type: :page, model_name: self.name)
          @available_actions << action
          @current_action = action
          @available_tabs << CmAdmin::Models::Tab.new(tab_name, custom_action, display_if, &block)
        end
        yield if block
      end

      def row(display_if: nil, &block)
        @available_fields[@current_action.name.to_sym] ||= []
        @available_fields[@current_action.name.to_sym] << CmAdmin::Models::Row.new(@current_action, @model, display_if, &block)
      end

      def cm_section(section_name, display_if: nil, col_size: nil, &block)
        @available_fields[@current_action.name.to_sym] ||= []
        @available_fields[@current_action.name.to_sym] << CmAdmin::Models::Section.new(section_name, @current_action, @model, display_if, col_size, &block)
      end

      # This method is deprecated. Use cm_section instead.
      def cm_show_section(section_name, display_if: nil, &block)
        cm_section(section_name, display_if: display_if, &block)
      end

      def column(field_name, options={})
        @available_fields[@current_action.name.to_sym] ||= []
        if @available_fields[@current_action.name.to_sym].select{|x| x.lockable}.size > 0 && options[:lockable]
          raise 'Only one column can be locked in a table.'
        end

        duplicate_columns = @available_fields[@current_action.name.to_sym].filter{|x| x.field_name.to_sym == field_name}
        terminate = false

        if duplicate_columns.size.positive?
          duplicate_columns.each do |column|
            if options[:field_type].to_s != 'association'
              terminate = true
            elsif options[:field_type].to_s == 'association' && column.association_name.to_s == options[:association_name].to_s
              terminate = true
            end
          end
        end

        unless terminate
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
      def custom_action(name: nil, page_title: nil, page_description: nil, display_name: nil, verb: nil, layout: nil, layout_type: nil, partial: nil, path: nil, display_type: nil, modal_configuration: {}, url_params: {}, display_if: lambda { |arg| return true }, route_type: nil, icon_name: 'fa fa-th-large', &block)
        action = CmAdmin::Models::CustomAction.new(
          page_title: page_title, page_description: page_description,
          name: name, display_name: display_name, verb: verb, layout: layout,
          layout_type: layout_type, partial: partial, path: path,
          parent: self.current_action.name, display_type: display_type, display_if: display_if,
          action_type: :custom, route_type: route_type, icon_name: icon_name, modal_configuration: modal_configuration,
          model_name: self.name, url_params: url_params, &block)
        @available_actions << action
        # self.class.class_eval(&block)
      end

      def bulk_action(name: nil, display_name: nil, display_if: lambda { |arg| return true }, redirection_url: nil, icon_name: nil, verb: nil, display_type: nil, modal_configuration: {}, route_type: nil, partial: nil, &block)
        bulk_action = CmAdmin::Models::BulkAction.new(
          name: name, display_name: display_name, display_if: display_if, modal_configuration: modal_configuration,
          redirection_url: redirection_url, icon_name: icon_name, action_type: :bulk_action,
          verb: verb, display_type: display_type, route_type: route_type, partial: partial, &block
        )
        @available_actions << bulk_action
      end

      def filter(db_column_name, filter_type, options={})
        @filters << CmAdmin::Models::Filter.new(db_column_name: db_column_name, filter_type: filter_type, options: options)
      end

      def sort_direction(direction = :desc)
        raise ArgumentError, "Select a valid sort direction like #{CmAdmin::Models::Action::VALID_SORT_DIRECTION.join(' or ')} instead of #{direction}" unless CmAdmin::Models::Action::VALID_SORT_DIRECTION.include?(direction.to_sym.downcase)

        @current_action.sort_direction = direction.to_sym if @current_action
      end

      def sort_column(column = :created_at)
        @current_action.sort_column = column.to_sym if @current_action
      end
    end
  end
end
