require 'pagy'
module CmAdmin
  module ViewHelpers
    module NavigationHelper
      include Pagy::Frontend
      def sidebar_navigation
        CmAdmin.cm_admin_models.map { |model|
          path = CmAdmin::Engine.mount_path + '/' + model.name.underscore.pluralize
          "<a href=#{path}><div class='menu-item'>
            <span class='menu-icon'><i class='fa fa-th-large'></i></span>
            #{model.name}
          </div></a>".html_safe
        }.join.html_safe
      end

    end
  end
end
