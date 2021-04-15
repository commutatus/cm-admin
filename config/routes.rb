CmAdmin::Engine.routes.draw do
  controller 'main' do
    get '/', action: 'dashboard'
  end

    # Defining action routes for each model
  CmAdmin.cm_admin_models.each do |model|
    model.available_actions.each do |act|
      scope model.name.tableize do
        send(act.verb, act.name, to: "#{model.name.underscore}##{act.name}")
      end
    end
  end
end
