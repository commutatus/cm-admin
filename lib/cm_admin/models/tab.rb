module CmAdmin
  module Models
    class Tab

      attr_accessor :nav_item_name, :custom_action

      def initialize(nav_item_name, custom_action)
        @nav_item_name = nav_item_name
        @custom_action = custom_action
      end
    end
  end
end