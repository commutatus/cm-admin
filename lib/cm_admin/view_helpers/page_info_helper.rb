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
            when :button
              custom_action_button(custom_action, current_action_name)
            when :modal
              custom_modal_button(custom_action)
            end
          end
        end
      end

      def custom_action_button(custom_action, current_action_name)
        if current_action_name == "index"
          link_to custom_action.name.titleize, @model.ar_model.table_name + '/' + custom_action.path, class: 'secondary-btn ml-2', method: custom_action.verb
        elsif current_action_name == "show"
          link_to custom_action.name.titleize, custom_action.path.gsub(':id', params[:id]), class: 'secondary-btn ml-2', method: custom_action.verb
        end
      end

      def custom_modal_button(custom_action)
        link_to custom_action.name.titleize, '', class: 'secondary-btn ml-2', data: { bs_toggle: "modal", bs_target: "##{custom_action.name.classify}Modal" }
      end
    end
  end
end
