CmAdmin::Engine.routes.draw do
  controller 'main' do
    get '/', action: 'dashboard'
  end

    # Defining action routes for each model
  CmAdmin.cm_admin_models.each do |model|
    model.available_actions.each do |act|
      scope model.name.tableize do
        send(act[:verb], act[:action], to: "#{model.name.underscore}##{act[:action]}")
      end
    end
  end
end
