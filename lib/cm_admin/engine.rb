require 'rails'
module CmAdmin
  class Engine < Rails::Engine
    isolate_namespace CmAdmin
  end
end
