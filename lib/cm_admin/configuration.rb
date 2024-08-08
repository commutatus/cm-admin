module CmAdmin
  class Configuration
    attr_accessor :layout, :included_models, :cm_admin_models, :sidebar

    def initialize
      @layout = 'admin'
      @included_models = []
      @cm_admin_models = []
      @sidebar = []
    end
  end
end
