module CmAdmin
  module ViewHelpers
    module PageInfoHelper
      def page_title
        @action.title || @model.title || "#{@model.ar_model.name} | #{@action.name&.titleize} | Admin"
      end
    end
  end
end
