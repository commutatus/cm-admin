module CmAdmin
  class Configuration
    attr_accessor :included_models

    def initialize
      @included_models ||= []
    end

  end

end
