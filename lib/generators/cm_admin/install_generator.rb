module CmAdmin
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    desc <<-DESC.strip_heredoc
      Generates layout for the entire admin panel

      For example:
        rails g cm_admin:install

      It copies the respectively layout files and the necessary asset files.

    DESC

    def add_required_gems
      gem 'slim'
      system("yarn add bootstrap")
      system("yarn add font-awesome")
      system("yarn add select2")
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
