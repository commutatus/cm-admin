require 'pagy'
module CmAdmin
  module ViewHelpers
    module NavigationHelper
      include Pagy::Frontend
      def navigation_links(navigation_type)
        CmAdmin.config.cm_admin_models.map { |model|
          if model.is_visible_on_sidebar
            path = CmAdmin::Engine.mount_path + '/' + model.name.underscore.pluralize
            if policy([:cm_admin, model.name.classify.constantize]).index?
              if navigation_type == "sidebar"
                content_tag(:a, href: path) do
                  content_tag(:div, class: 'menu-item') do
                    content_tag(:span, class: 'menu-icon') do
                      concat tag.i class: "#{model.icon_name}"
                    end +
                    model.name.pluralize
                  end
                end
              elsif navigation_type == "quick_links"
                content_tag(:a, href: path, class: 'visible') do
                  content_tag(:div, class: 'result-item') do
                    content_tag(:span) do
                      concat tag.i class: "#{model.icon_name}"
                    end +
                    content_tag(:span) do
                      model.name
                    end
                  end
                end
              end
            end
          end
        }.join.html_safe
      end
    end
  end
end
