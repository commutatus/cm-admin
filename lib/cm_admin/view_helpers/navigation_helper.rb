module CmAdmin
  module ViewHelpers
    module NavigationHelper
      def sidebar_navigation
        CmAdmin.cm_admin_models.map { |model|
          path = CmAdmin::Engine.routes.find_script_name({}) + '/' + model.name.downcase.pluralize
          "<a href=#{path}><div class='menu-item'>
            <span class='menu-icon'><i class='fa fa-th-large'></i></span>
            #{model.name}
          </div></a>".html_safe
        }.join.html_safe
      end
    end
  end
end
