CmAdmin::Engine.routes.draw do
  controller 'static' do
    get '/', action: 'dashboard'
    get '/access-denied', action: 'error_403'
  end

  controller 'exports' do
    post '/export_to_file', action: 'export'
  end

  # Defining action routes for each model
  CmAdmin.config.cm_admin_models.each do |model|
    if model.importer
      scope model.name.tableize do
        send(:get, 'import', to: "#{model.name.underscore}#import_form", as: "#{model.name.underscore}_import_form")
        send(:post, 'import', to: "#{model.name.underscore}#import", as: "#{model.name.underscore}_import")
      end
    end

    scope model.name.tableize do
      send(:post, 'manage_column', to: "#{model.name.underscore}#manage_column", as: "#{model.name.underscore}_manage_column")
    end
    
    model.available_actions.sort_by {|act| act.name}.each do |act|
      scope model.name.tableize do
        # Define route only when action trail related field is present
        if act.name == 'history'
          if defined?(model.ar_model.new.current_action_name)
            send(:get, ':id/history', to: "#{model.name.underscore}#history", as: "#{model.name.underscore}_history")
          end
        else
          send(act.verb, act.path.present? ? act.path : act.name, to: "#{model.name.underscore}##{act.name}", as: "#{model.name.underscore}_#{act.name}")
        end
      end
    end
  end
end
