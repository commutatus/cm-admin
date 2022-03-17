require 'rails/generators'
module CmAdmin
  class InstallGenerator < Rails::Generators::Base
    def add_required_gems
      gem 'slim'
      gem 'simple_form'
      system("yarn add bootstrap")
      system("yarn add @fortawesome/fontawesome-free")
      system("yarn add select2")
      system("yarn add daterangepicker")
      system("yarn add jgrowl")
    end

    def copy_layout_file
      copy_file "layouts/_side_navbar.html.slim", "app/views/layouts/_side_navbar.html.slim"
      copy_file "layouts/_navbar.html.slim", "app/views/layouts/_navbar.html.slim"
      remove_file "app/views/layouts/application.html.erb"
      copy_file "layouts/application.html.slim", "app/views/layouts/application.html.slim"
    end

    def copy_asset_file
      copy_file "assets/images/cm.png", "app/assets/images/cm.png"
      directory "assets/stylesheets/", "app/assets/stylesheets/"
      remove_file "app/assets/stylesheets/application.css"
    end
  end
end
