CmAdmin::Engine.routes.draw do
  controller 'main' do
    get '/', action: 'dashboard'
  end
end
