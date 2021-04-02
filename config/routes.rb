CmAdmin::Engine.routes.draw do
  controller 'main' do
    get '/', action: 'dashboard'
    scope ':model_name' do
      post '/bulk_action', action: :bulk_action, as: 'bulk_action'
      CmAdmin::Config::Actions.all.each { |action| match action[:route_fragment], action: action[:action_name], as: action[:action_name], via: action[:http_method] }
    end
  end

    # Defining action routes for each model
  # CmAdmin.cm_admin_models.each do |model|
  #   model.available_actions.each do |act|
  #     scope model.name.tableize do
  #       send(act[:verb], act[:action], to: "#{model.name.underscore}##{act[:action]}")
  #     end
  #   end
  # end
end
