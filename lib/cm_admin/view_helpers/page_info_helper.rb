module CmAdmin
  module ViewHelpers
    module PageInfoHelper
      def page_title
        @action.title || @model.title || "#{@model.ar_model.name} | #{@action.name&.titleize} | Admin"
      end

      def action_title
        if @model.current_action.page_title
          title = @model.current_action.page_title
        else
          title = "#{@model.name}"
          case action_name
          when 'index'
            title + " list record"
          when 'show'
            title + " detail"
          when 'new'
            title + " create record"
          when 'edit'
            title + " edit record"
          end
        end
      end

      def action_description
        if @model.current_action.page_description
          title = @model.current_action.page_description
        else
          title = "#{@model.name}"
          case action_name
          when 'index'
            title + " list record"
          when 'show'
            title + " detail"
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
        end
      end
    end
  end
end
