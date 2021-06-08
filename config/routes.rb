CmAdmin::Engine.routes.draw do
  controller 'main' do
    get '/', action: 'dashboard'
  end

  post '/export_to_file', to: '/cm_admin/exports#export'
  get '/ajax_download', to: 'cm_admin/exports#ajax_download'

  # Defining action routes for each model
  CmAdmin.cm_admin_models.each do |model|
    model.available_actions.each do |act|
      scope model.name.tableize do
        send(act.verb, act.path.present? ? act.path : act.name, to: "#{model.name.underscore}##{act.name}")
      end
    end
  end
end
