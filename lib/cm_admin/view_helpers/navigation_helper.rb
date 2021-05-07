require 'pagy'
module CmAdmin
  module ViewHelpers
    module NavigationHelper
      include Pagy::Frontend
      def sidebar_navigation
        CmAdmin.cm_admin_models.map { |model|
          path = CmAdmin::Engine.mount_path + '/' + model.name.downcase.pluralize
          "<a href=#{path}><div class='menu-item'>
            <span class='menu-icon'><i class='fa fa-th-large'></i></span>
            #{model.name}
          </div></a>".html_safe
        }.join.html_safe
      end

      def cm_paginate(facets)
        tag.div class: 'cm-pagination' do
          if facets.previous_page != false
            previous_page = tag.div class: 'cm-pagination__item', data: { behaviour: 'previous-page'} do
              tag.span "Previous"
            end
          end
          current_page = tag.div class: 'cm-pagination__item', data: {sort_column: facets.sort[:sort_column], sort_direction: facets.sort[:sort_direction], page: facets.current_page, behaviour: 'current-page' } do
            "Showing #{facets.current_page} of #{facets.total_pages} pages"
          end

          if facets.next_page != false
            next_page = tag.div class: 'cm-pagination__item', data: { behaviour: 'next-page'} do
              tag.span "Next"
            end
          end
          (previous_page || ActiveSupport::SafeBuffer.new) + current_page + (next_page || ActiveSupport::SafeBuffer.new)
        end
      end

    end
  end
end
