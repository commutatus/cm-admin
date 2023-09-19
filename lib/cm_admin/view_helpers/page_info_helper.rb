module CmAdmin
  module ViewHelpers
    module PageInfoHelper
      def page_title
        @action.title || @model.title || "#{@model.ar_model.name} | #{@action.name&.titleize} | Admin"
      end

      def action_title
        show_action = CmAdmin::Models::Action.find_by(@model, name: 'show')
        title = @model.current_action.page_title || show_action.page_title
        if title
          title = (title.class == Symbol) ? @ar_object.send(title) : title
        else
          title = "#{@model.name}"
          case action_name
          when 'index'
            title + " list record"
          when 'new'
            title + " create record"
          when 'edit'
            title + " edit record"
          end
        end
      end

      def action_description
        show_action = CmAdmin::Models::Action.find_by(@model, name: 'show')
        if @model.current_action.page_description
          title = @model.current_action.page_description
        elsif show_action.page_description
          title = show_action.page_description
        else
          title = "#{@model.name}"
          case action_name
          when 'index'
            title + " list record"
          when 'new'
            title + " new record"
          when 'edit'
            title + " edit record"
          end
        end
      end

      def page_url(action_name=@action.name, ar_object=nil)
        base_path = CmAdmin::Engine.mount_path + '/' + @model.name.downcase.pluralize
        case action_name
        when 'index'
          base_path
        when 'new'
          base_path + '/new'
        when 'edit'
          base_path + "/#{ar_object.id}" + '/edit'
        when 'destroy'
          base_path + "/#{ar_object.id}"
        end
      end

      def custom_action_items(custom_action, current_action_name)
        if custom_action.name.present? && policy([:cm_admin, @model.name.classify.constantize]).send(:"#{custom_action.name}?")
          if custom_action.display_if.call(@ar_object)
            case custom_action.display_type
            when :icon_only
              custom_action_icon(custom_action, current_action_name)
            when :button
              custom_action_button(custom_action, current_action_name)
            when :modal
              custom_modal_button(custom_action)
            when :page
              link_to custom_action_title(custom_action), "#{@model.ar_model.table_name}/#{custom_action.path}", class: 'btn-secondary ms-2', method: custom_action.verb
            end
          end
        end
      end

      def custom_action_icon(custom_action, current_action_name)
        button_to cm_admin.send("#{@model.name.underscore}_#{custom_action.name}_path"), method: :post, params: {selected_ids: ''} do
          content_tag(:span) do
            content_tag(:i, '', class: custom_action.icon_name)
          end
        end
      end

      def custom_action_button(custom_action, current_action_name)
        if current_action_name == "index"
          button_to custom_action_title(custom_action), @model.ar_model.table_name + '/' + custom_action.path, class: 'btn-secondary ms-2', method: custom_action.verb
        elsif current_action_name == "show"
          button_to custom_action_title(custom_action), custom_action.path.gsub(':id', params[:id]), class: 'btn-secondary ms-2', method: custom_action.verb
        end
      end

      def custom_modal_button(custom_action)
        link_to custom_action_title(custom_action), '', class: 'btn-secondary ms-2', data: { bs_toggle: "modal", bs_target: "##{custom_action.name.classify}Modal-#{@ar_object.id}" }
      end

      def custom_action_title(custom_action)
         custom_action.display_name.to_s.presence || custom_action.name.to_s.titleize
      end

      def tab_display_name(nav_item_name)
        nav_item_name.instance_of?(Symbol) ? nav_item_name.to_s.titleize : nav_item_name.to_s
      end

      def user_full_name
        return false unless current_user
        return current_user.full_name if defined?(current_user.full_name)
        current_user.email.split('@').first
      end
    end
  end
end
