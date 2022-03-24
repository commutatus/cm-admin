module CmAdmin
  class Configuration
    attr_accessor :layout, :included_models, :cm_admin_models
    
    def initialize
      @included_models = []
      @cm_admin_models = []
    end
  end
end