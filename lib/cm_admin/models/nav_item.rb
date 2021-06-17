module CmAdmin
  module Models
    class NavItem

      attr_accessor :nav_item_name, :redirection_url, :is_active

      def initialize(nav_item_name, redirection_url = '#', is_active = false)
        @nav_item_name = nav_item_name
        @redirection_url = redirection_url
        @is_active = is_active
      end
    end
  end
end