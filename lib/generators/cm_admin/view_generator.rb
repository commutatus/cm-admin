module CmAdmin
  module ViewActionTemplate
    def copy_index_files
      template "views/index.erb", "app/views/admin/#{name}/index.html.slim"
      template "views/_table.erb", "app/views/admin/#{name}/_table.html.slim"
      inject_into_file 'app/views/layouts/_side_navbar.html.slim', after: ".sidebar-menu__tabs-wrapper" do
        "\n
      = link_to '/admin/#{name}', class: 'tab-link'
        .tab-item class=\"\#{(controller_name == '#{name}' ) ? 'active' : ''}\"
          span.p-4.tab-name.f14 #{name.titleize}\n"
      end
      puts "
      -------------------------------------------------------------------
      # Important
      Run the spotlight filter generator which will generate the filter
      partial and controller file. Run the following with required filter option.
      rails g spotlight_search:filter #{name} --filters scope:datatype
      -------------------------------------------------------------------------"
    end

    def copy_show_files
      template "views/show.erb", "app/views/admin/#{name}/show.html.slim"
    end

    def copy_form_files
      template "views/new.erb", "app/views/admin/#{name}/new.html.slim"
      template "views/edit.erb", "app/views/admin/#{name}/edit.html.slim"
      template "views/_form.erb", "app/views/admin/#{name}/_form.html.slim"
    end

    def copy_devise_files
      template "views/reset_password.erb", "app/views/devise/passwords/new.html.slim"
      template "views/sign_in.erb", "app/views/devise/sessions/new.html.slim"
    end
  end

  class ViewGenerator < Rails::Generators::NamedBase
    include ViewActionTemplate
    desc <<-DESC.strip_heredoc
      Generate views for specific action of the model in admin
      Use -c to specify which column names you want to be present on page.
      Atleast one option is mandatory.
      For example:
        rails g cm_admin:view NAME page_type -c options
        rails g cm_admin:view products form -c title:string price:integer
        rails g cm_admin:view products index -c title price

      NAME is the table name
      page_type is the page you want to copy files. It can be the following
      index, show, form.

      This will create a files respectively at app/views/admin/#{name}/***.html.slim

    DESC

    source_root File.expand_path('templates', __dir__)

    argument :page_type, required: true, default: nil,
                         desc: "The scope to copy views to"
    class_option :column_names, aliases: "-c", type: :array, required: true,
                  desc: "Select specific columns in the files to be be added."

    def create_new_file
      if page_type == 'index'
        copy_index_files
      elsif page_type == 'form'
        copy_form_files
      elsif page_type == 'show'
        copy_show_files
      elsif page_type == 'devise'
        copy_devise_files
      else
        puts "Wrong page_type provided. It can be either index or show"
      end
    end

  end
end
