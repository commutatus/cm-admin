require 'pagy'
module CmAdmin
  module ViewHelpers
    module NavigationHelper
      include Pagy::Frontend
      def navigation_links(navigation_type)
        CmAdmin.cm_admin_models.map { |model|
          path = CmAdmin::Engine.mount_path + '/' + model.name.underscore.pluralize
          if navigation_type == "sidebar"
            content_tag(:a, href: path) do
              content_tag(:div, class: 'menu-item') do
                content_tag(:span, class: 'menu-icon') do
                  concat tag.i class: 'fa fa-th-large'
                end +
                model.name
              end
            end
          elsif navigation_type == "quick_links"
            content_tag(:a, href: path, class: 'visible') do
              content_tag(:div, class: 'result-item') do
                content_tag(:span) do
                  concat tag.i class: 'fa fa-th-large'
                end +
                content_tag(:span) do
                  model.name
                end
              end
            end
          end
        }.join.html_safe
      end
    end
  end
end
