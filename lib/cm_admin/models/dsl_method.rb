module CmAdmin
  module Models
    module DslMethod
      extend ActiveSupport::Concern

      # Create a table for index page with pagination.
      #
      # @param page_title [String] the title of page
      # @param page_description [String] the description of page
      # @param partial [String] the partial path of page
      # @param view_type [Symbol] view type of page, `:table`, `:card` or `:kanban
      # @example Index page
      #  cm_index(page_title: "Home", page_description: 'Home page', partial: 'pages/home', view_type: :table)
      def cm_index(page_title: nil, page_description: nil, partial: nil, view_type: :table)
        @current_action = CmAdmin::Models::Action.find_by(self, name: 'index')
        @current_action.set_values(page_title, page_description, partial, view_type)
        yield
      end

      # Create a view for show page
      #
      # @param page_title [String] or [Symbol] the title of page, if symbol passed, it will be a method name on model
      # @param page_description [String] the description of page
      # @param partial [String] the partial path of page
      #
      # @example Showing page
      #   cm_show(page_title: "Home", page_description: 'Home page', partial: 'pages/home')
      def cm_show(page_title: nil, page_description: nil, partial: nil)
        @current_action = CmAdmin::Models::Action.find_by(self, name: 'show')
        @current_action.set_values(page_title, page_description, partial)
        yield
      end

      # Create a form for edit action
      #
      # @param page_title [String] or [Symbol] the title of page, if symbol passed, it will be a method name on model
      # @param page_description [String] the description of page
      # @param partial [String] the partial path of page
      # @param redirect_to [Proc, nil] A lambda that takes the current object and redirect to path after update
      #
      # @example Editing page with a redirect
      #   cm_edit(page_title: "Home", redirect_to: ->(current_object) { "/pages/#{current_object.id}" })
      def cm_edit(page_title: nil, page_description: nil, partial: nil, redirect_to: nil)
        @current_action = CmAdmin::Models::Action.find_by(self, name: 'edit')
        @current_action.set_values(page_title, page_description, partial, redirect_to)
        yield
      end

      # Create a form for new action
      #
      # @param page_title [String] the title of page
      # @param page_description [String] the description of page
      # @param partial [String] the partial path of page
      # @param redirect_to [Proc, nil] A lambda that takes the current object and redirect to path after create
      #
      # @example Creating a new page with a redirect
      #   cm_new(page_title: "Home", redirect_to: ->(current_object) { "/pages/#{current_object.id}" })
      def cm_new(page_title: nil, page_description: nil, partial: nil, redirect_to: nil)
        @current_action = CmAdmin::Models::Action.find_by(self, name: 'new')
        @current_action.set_values(page_title, page_description, partial, redirect_to)
        yield
      end

      # Set page title for current action
      # @param title [String] the title of page
      def page_title(title)
        return unless @current_action

        @current_action.page_title = title
      end

      # Set page description for current action
      # @param description [String] the description of page
      def page_description(description)
        return unless @current_action

        @current_action.page_description = description
      end

      # Set kanban view for current action
      # @param column_name [String] the name of column
      # @param exclude [Array] the array of fields to exclude
      # @param only [Array] the array of fields to include
      def kanban_view(column_name, exclude: [], only: [])
        return unless @current_action

        @current_action.kanban_attr[:column_name] = column_name
        @current_action.kanban_attr[:exclude] = exclude
        @current_action.kanban_attr[:only] = only
      end

      # Set scopes for current action
      # @param scopes [Array] the array of scopes
      def scope_list(scopes = [])
        return unless @current_action

        @current_action.scopes = scopes
      end

      # Create a new tab on show page.
      #
      # @param tab_name [String] or [Symbol] the name of tab
      # @param custom_action [String] the name of custom action
      # @param associated_model [String] the name of associated model
      # @param layout_type [String] the layout type of tab, `'cm_association_index'`, `'cm_association_show'`
      # @param layout [String] the layout of tab
      # @param partial [String] the partial path of tab
      # @param display_if [Proc] A lambda that takes the current object and return true or false
      #
      # @example Creating a tab
      #  tab(:comments, 'comment', associated_model: 'comments', layout_type: 'cm_association_index')
      def tab(tab_name, custom_action, associated_model: nil, layout_type: nil, layout: nil, partial: nil, display_if: nil, &block)
        if custom_action.to_s == ''
          @current_action = CmAdmin::Models::Action.find_by(self, name: 'show')
          @available_tabs << CmAdmin::Models::Tab.new(tab_name, '', display_if, &block)
        else
          action = CmAdmin::Models::Action.new(name: custom_action.to_s, verb: :get, path: ':id/' + custom_action,
                                               layout_type:, layout:, partial:, child_records: associated_model,
                                               action_type: :custom, display_type: :page, model_name: name)
          @available_actions << action
          @current_action = action
          @available_tabs << CmAdmin::Models::Tab.new(tab_name, custom_action, display_if, &block)
        end
        yield if block
      end

      # Create a new row on page or form.
      # @param display_if [Proc] A lambda that takes the current object and return true or false
      # @param html_attrs [Hash] A hash that contains html attributes
      # @example Creating a row
      #  row(display_if: ->(current_object) { current_object.name == 'John' }, html_attrs: { class: 'row-class' }) do
      def row(display_if: nil, html_attrs: nil, &block)
        @available_fields[@current_action.name.to_sym] ||= []
        @available_fields[@current_action.name.to_sym] << CmAdmin::Models::Row.new(@current_action, @model, display_if, html_attrs, &block)
      end

      # Create a new section on page or form.
      # @param section_name [String] the name of section
      # @param display_if [Proc] A lambda that takes the current object and return true or false
      # @param col_size [Integer] the size of column according to grid view
      # @param html_attrs [Hash] A hash that contains html attributes

      # @example Creating a section
      #  cm_section('Basic Information', display_if: ->(current_object) { current_object.name == 'John' }, col_size: 6, html_attrs: { class: 'section-class' }) do
      def cm_section(section_name, display_if: nil, col_size: nil, html_attrs: nil, &block)
        @available_fields[@current_action.name.to_sym] ||= []
        @available_fields[@current_action.name.to_sym] << CmAdmin::Models::Section.new(section_name, @current_action, @model, display_if, html_attrs, col_size, &block)
      end

      # @deprecated Use {#cm_section} instead of this method
      def cm_show_section(section_name, display_if: nil, html_attrs: nil, &block)
        cm_section(section_name, display_if:, html_attrs:, &block)
      end

      # Create a new column on index layout.
      # @param field_name [String] the name of field
      # @param field_type [Symbol] the type of field, :string, :text, :image, :date, :rich_text, :time, :integer, :decimal, :custom, :datetime, :money, :money_with_symbol, :link, :association, :enum, :tag, :attachment, :drawer
      # @param header [String] the header of field
      # @param format [String] the format of field for date field
      # @param helper_method [Symbol] the helper method for field, should be defined in custom_helper.rb file, will take two arguments, `record` and `field_name`
      # @param height [Integer] the height of field for image field
      # @param width [Integer] the width of field for image field
      # @params custom_link [String] the custom link for field
      # @params tag_class [Hash] the tag class for field, example: { approved: 'completed', draft: 'active-two', rejected: 'danger' }, this will add css class to tag
      # @params display_if [Proc] A lambda that takes the current object and return true or false
      # @example Creating a column
      #  column('name', field_type: :string)
      def column(field_name, options = {})
        @available_fields[@current_action.name.to_sym] ||= []
        raise 'Only one column can be locked in a table.' if @available_fields[@current_action.name.to_sym].select { |x| x.lockable }.size > 0 && options[:lockable]

        duplicate_columns = @available_fields[@current_action.name.to_sym].filter { |x| x.field_name.to_sym == field_name }
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

        return if terminate

        @available_fields[@current_action.name.to_sym] << CmAdmin::Models::Column.new(field_name, options)
      end

      # Get all columns for a model for index layout.
      # @param exclude [Array] the array of fields to exclude
      # @example Getting all columns
      #  all_db_columns(exclude: ['id'])
      def all_db_columns(options = {})
        field_names = instance_variable_get(:@ar_model)&.columns&.map { |x| x.name.to_sym }
        if options.include?(:exclude) && field_names
          excluded_fields = ([] << options[:exclude]).flatten.map(&:to_sym)
          field_names -= excluded_fields
        end
        field_names.each do |field_name|
          column field_name
        end
      end

      # Create a new custom action for model
      # @param name [String] the name of action
      # @param page_title [String] the title of page
      # @param page_description [String] the description of page
      # @param display_name [String] the display name of action
      # @param verb [String] the verb of action, `get`, `post`, `put`, `patch` or `delete`
      # @param layout [String] the layout of action
      # @param layout_type [String] the layout type of action, `'cm_association_index'`, `'cm_association_show'`
      # @param partial [String] the partial path of action
      # @param path [String] the path of action
      # @param display_type [Symbol] the display type of action, `:button`, `:modal`
      # @param modal_configuration [Hash] the configuration of modal
      # @param url_params [Hash] the url params of action
      # @param display_if [Proc] A lambda that takes the current object and return true or false
      # @param route_type [String] the route type of action, `member`, `collection`
      # @param icon_name [String] the icon name of action, follow font-awesome icon name
      # @example Creating a custom action with modal
      #  custom_action name: 'approve', route_type: 'member', verb: 'patch', icon_name: 'fa-regular fa-circle-check', path: ':id/approve', display_type: :modal, display_if: lambda(&:draft?), modal_configuration: { title: 'Approve Post', description: 'Are you sure you want approve this post', confirmation_text: 'Approve' }
      # @example Creating a custom action with button
      #  custom_action name: 'approve', route_type: 'member', verb: 'patch', icon_name: 'fa-regular fa-circle-check', path: ':id/approve', display_type: :button, display_if: lambda(&:draft?)
      def custom_action(name: nil, page_title: nil, page_description: nil, display_name: nil, verb: nil, layout: nil, layout_type: nil, partial: nil, path: nil, display_type: nil, modal_configuration: {}, url_params: {}, display_if: ->(_arg) { true }, route_type: nil, icon_name: 'fa fa-th-large', &block)
        action = CmAdmin::Models::CustomAction.new(
          page_title:, page_description:,
          name:, display_name:, verb:, layout:,
          layout_type:, partial:, path:,
          parent: current_action.name, display_type:, display_if:,
          action_type: :custom, route_type:, icon_name:, modal_configuration:,
          model_name: self.name, url_params:, &block
        )
        @available_actions << action
      end

      # Create a new bulk action for model
      # @param name [String] the name of action
      # @param display_name [String] the display name of action
      # @param display_if [Proc] A lambda that takes the current object and return true or false
      # @param redirection_url [String] the redirection url of action
      # @param icon_name [String] the icon name of action, follow font-awesome icon name
      # @param verb [String] the verb of action, `get`, `post`, `put`, `patch` or `delete`
      # @param display_type [Symbol] the display type of action, `:page`, `:modal`
      # @param modal_configuration [Hash] the configuration of modal
      # @param route_type [String] the route type of action, `member`, `collection`
      # @param partial [String] the partial path of action
      # @example Creating a bulk action
      #  bulk_action name: 'approve', display_name: 'Approve', display_if: lambda { |arg| arg.draft? }, redirection_url: '/posts', icon_name: 'fa-regular fa-circle-check', verb: :patch, display_type: :modal, modal_configuration: { title: 'Approve Post', description: 'Are you sure you want approve this post', confirmation_text: 'Approve' }
      def bulk_action(name: nil, display_name: nil, display_if: ->(_arg) { true }, redirection_url: nil, icon_name: nil, verb: nil, display_type: nil, modal_configuration: {}, route_type: nil, partial: nil, &block)
        bulk_action = CmAdmin::Models::BulkAction.new(
          name:, display_name:, display_if:, modal_configuration:,
          redirection_url:, icon_name:, action_type: :bulk_action,
          verb:, display_type:, route_type:, partial:, &block
        )
        @available_actions << bulk_action
      end

      # Create a new filter for model
      # @param db_column_name [String] the name of column
      # @param filter_type [String] the type of filter, :date, :multi_select, :range, :search, :single_select
      # @param placeholder [String] the placeholder of filter
      # @param helper_method [String] the helper method for filter, should be defined in custom_helper.rb file
      # @param filter_with [Symbol] filter with scope name on model
      # @param collection [Array] the collection of filter, use with single_select or multi_select
      # @example Creating a filter
      #  filter('name', :search)
      #  filter('created_at', :date)
      #  filter('status', :single_select, collection: ['draft', 'published'])
      #  filter('status', :multi_select,  helper_method: 'status_collection')
      def filter(db_column_name, filter_type, options = {})
        @filters << CmAdmin::Models::Filter.new(db_column_name:, filter_type:, options:)
      end

      # Set sort direction for filters
      # @param direction [Symbol] the direction of sort, `:asc`, `:desc`
      # @example Setting sort direction
      #  sort_direction(:asc)
      def sort_direction(direction = :desc)
        raise ArgumentError, "Select a valid sort direction like #{CmAdmin::Models::Action::VALID_SORT_DIRECTION.join(' or ')} instead of #{direction}" unless CmAdmin::Models::Action::VALID_SORT_DIRECTION.include?(direction.to_sym.downcase)

        @current_action.sort_direction = direction.to_sym if @current_action
      end

      # Set sort column for filters
      # @param column [Symbol] the column name
      # @example Setting sort column
      #   sort_column(:created_at)
      def sort_column(column = :created_at)
        @current_action.sort_column = column.to_sym if @current_action
      end
    end
  end
end
