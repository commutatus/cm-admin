module CmAdmin
  module ViewHelpers
    # Helper for tabs
    module TabHelper
      def tab_title(tab)
        if tab.nav_item_custom_name.present?
          tab.nav_item_custom_name.to_s
        else
          tab.nav_item_default_name.to_s.titleize
        end
      end
    end
  end
end
