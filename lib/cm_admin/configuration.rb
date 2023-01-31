module CmAdmin
  class Configuration
    attr_accessor :layout, :included_models, :cm_admin_models, :authorized_roles

    def initialize
      @layout = 'admin'
      @included_models = []
      @cm_admin_models = []
      @authorized_roles = []
    end

  end
end