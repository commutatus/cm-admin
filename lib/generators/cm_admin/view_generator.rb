module CmAdmin
  class ViewGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('templates', __dir__)

    argument :page_type, required: true, default: nil,
                         desc: "The scope to copy views to"
    class_option :column_names, aliases: "-c", type: :array, desc: "Select specific view directories to generate (confirmations, passwords, registrations, sessions, unlocks, mailer)"

    def create_new_file
      if page_type == 'index'
        copy_index_files
      elsif page_type == 'form'
        copy_show_files
      else
        puts "Wrong page_type provided. It can be either index or show"
      end
    end

    def copy_index_files
      puts "came here #{options[:column_names]}"
      template "views/index.erb", "app/views/admin/#{name}/index.html.slim"
      template "views/_table.erb", "app/views/admin/#{name}/_table.html.slim"
      copy_file "views/_filters.html.slim", "app/views/admin/#{name}/_filters.html.slim"
    end

    def copy_show_files
      # puts "came here"
    end

    def copy_form_files
      template "views/_form.erb", "app/views/admin/#{name}/_form.html.slim"
    end
  end
end
