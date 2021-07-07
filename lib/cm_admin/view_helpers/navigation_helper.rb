require 'pagy'
module CmAdmin
  module ViewHelpers
    module NavigationHelper
      include Pagy::Frontend
      def navigation_links(navigation_type)
        CmAdmin.cm_admin_models.map { |model|
          path = CmAdmin::Engine.mount_path + '/' + model.name.underscore.pluralize
          if navigation_type == "sidebar"
            "<a href=#{path}><div class='menu-item'>
              <span class='menu-icon'><i class='fa fa-th-large'></i></span>
              #{model.name}
            </div></a>".html_safe
          elsif navigation_type == "quick_links"
            "<a href=#{path}><div class='result-item'>
            <span><i class='fa fa-th-large'></i></span>
            <span>#{model.name}</span>
          </div></a>".html_safe
          end

        }.join.html_safe
      end
    end
  end
end
