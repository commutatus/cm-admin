CmAdmin::Engine.routes.draw do
  controller 'static' do
    get '/', action: 'dashboard'
    get '/access-denied', action: 'error_403'
  end

  controller 'exports' do
    post '/export_to_file', action: 'export'
  end

  # Defining action routes for each model
  CmAdmin.cm_admin_models.each do |model|
    model.available_actions.each do |act|
      scope model.name.tableize do
        send(act.verb, act.path.present? ? act.path : act.name, to: "#{model.name.underscore}##{act.name}")
      end
    end
  end
end
