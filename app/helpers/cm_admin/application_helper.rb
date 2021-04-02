module CmAdmin
  module ApplicationHelper
    def sidebar_navigation
      CmAdmin.models.map { |model|
        "<div class='menu-item'>
          <span class='menu-icon'><i class='fa fa-th-large'></i></span>
          #{model.name}
        </div>".html_safe
      }.join.html_safe
    end
  end
end
