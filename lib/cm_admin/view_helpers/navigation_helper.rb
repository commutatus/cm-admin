require 'pagy'

module CmAdmin
  module ViewHelpers
    module NavigationHelper
      include Pagy::Frontend

      def navigation_links(navigation_type)
        sidebar = CmAdmin.config.sidebar

        if navigation_type == 'sidebar' && sidebar.present? && !sidebar.empty?
          sidebar.map do |item|
            content_tag(:a, href: item[:path] || nil) do
              content_tag(:div, class: 'menu-item') do
                content_tag(:div, class: 'menu-item-title') do
                  link_content = content_tag(:i, '', class: "menu-icon #{item[:icon]}")
                  link_content += content_tag(:span, item[:name])
                  concat(link_content)

                  if item[:include].present?
                    sub_menu = item[:include].map do |sub_item|
                      content_tag(:a, href: sub_item[:path] || nil) do
                        content_tag(:div, class: 'menu-sub-item') do
                          sub_link_content = content_tag(:i, '', class: "sub-menu-icon #{sub_item[:icon]}")
                          sub_link_content + content_tag(:span, sub_item[:name])
                        end
                      end
                    end.join.html_safe

                    concat(content_tag(:div, sub_menu.html_safe, class: 'menu-sub-list'))
                  end
                end
              end
            end
          end.join.html_safe
        else
          quick_links_content(navigation_type)
        end
      end

      def quick_links_content(navigation_type)
        CmAdmin.config.cm_admin_models.map do |model|
          next unless model.is_visible_on_sidebar

          path = CmAdmin::Engine.mount_path + '/' + model.name.underscore.pluralize
          if policy([:cm_admin, model.name.classify.constantize]).index?
            if navigation_type == 'sidebar'
              content_tag(:a, href: path) do
                content_tag(:div, class: 'menu-item') do
                  content_tag(:span, class: 'menu-icon') do
                    concat tag.i class: "#{model.icon_name}"
                  end +
                    model.model_name.titleize.pluralize
                end
              end
            elsif navigation_type == 'quick_links'
              content_tag(:a, href: path, class: 'visible') do
                content_tag(:div, class: 'result-item') do
                  content_tag(:span) do
                    concat tag.i class: "#{model.icon_name}"
                  end +
                    content_tag(:span) do
                      model.model_name
                    end
                end
              end
            end
          end
        end.join.html_safe
      end
    end
  end
end
