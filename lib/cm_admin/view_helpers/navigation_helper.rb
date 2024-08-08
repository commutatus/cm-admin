require 'pagy'

module CmAdmin
  module ViewHelpers
    module NavigationHelper
      include Pagy::Frontend

      def navigation_links(navigation_type)
        sidebar = CmAdmin.config.sidebar
        quick_links_content(navigation_type, sidebar)
      end

      private

      def sub_menu_link(sub_item, sidebar_item)
        if policy([:cm_admin, sidebar_item[:model].name.demodulize.classify.constantize]).send(sub_item[:method] + '?')
          sub_path = CmAdmin::Engine.mount_path + '/' + (sub_item[:method].underscore == 'index' ? sidebar_item[:model].name.demodulize.underscore.pluralize : sub_item[:method].underscore)
          content_tag(:a, href: sub_path || nil) do
            content_tag(:div, class: 'menu-sub-item') do
              sub_link_content = content_tag(:i, '', class: "sub-menu-icon #{sub_item[:icon]}")
              sub_link_content + content_tag(:span, sub_item[:name])
            end
          end
        end
      end

      def quick_links_content(navigation_type, sidebar = [])
        CmAdmin.config.cm_admin_models.map do |model|
          next unless model.is_visible_on_sidebar
          sidebar_item = sidebar.find { |item| item[:model].name.demodulize.underscore.downcase == model.model_name.underscore }
          check_sidebar = sidebar_item && sidebar_item[:include].present?

          permission_check = []
          if check_sidebar
            permission_check = sidebar_item[:include].map do |sub_item|
              policy([:cm_admin, sidebar_item[:model].name.demodulize.classify.constantize]).send(sub_item[:method] + '?')
            end
          end

          has_permission = permission_check.any?
          path = has_permission ? nil : CmAdmin::Engine.mount_path + '/' + model.name.underscore.pluralize

          if policy([:cm_admin, model.name.classify.constantize]).index? || has_permission
            if navigation_type == 'sidebar'
              content_tag(:a, href: path) do
                content_tag(:div, class: 'menu-item') do
                  content_tag(:span, class: 'menu-icon') do
                    concat tag.i class: "#{model.icon_name}"
                  end +
                  model.model_name.titleize.pluralize +
                  generate_sub_menu(model, sidebar_item)
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

      def generate_sub_menu(model, sidebar_item)
        return ''.html_safe unless sidebar_item && sidebar_item[:include].present?

        sub_menu = sidebar_item[:include].map do |sub_item|
          sub_menu_link(sub_item, sidebar_item)
        end.join.html_safe

        content_tag(:div, sub_menu, class: 'menu-sub-list')
      end
    end
  end
end
