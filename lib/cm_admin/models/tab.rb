module CmAdmin
  module Models
    class Tab

      attr_accessor :nav_item_name, :custom_action, :display_if

      def initialize(nav_item_name, custom_action, display_if)
        @nav_item_name = nav_item_name
        @custom_action = custom_action
        @display_if = display_if || lambda { |arg| return true }
      end
    end
  end
end