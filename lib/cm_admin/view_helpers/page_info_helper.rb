module CmAdmin
  module ViewHelpers
    module PageInfoHelper
      def page_title
        @action.title || @model.title || "#{@model.ar_model.name} | #{@action.name&.titleize} | Admin"
      end

      def page_url(action_name = @action.name)
        base_path = CmAdmin::Engine.mount_path + '/' + @model.name.downcase.pluralize
        case action_name
        when 'index'
          base_path
        when 'new'
          base_path + '/new'
        end
      end
    end
  end
end
