module CmAdmin
  module Config

    class << self
      attr_accessor :included_models

      def reset
        @included_models = []
        RailsAdmin::Config::Actions.reset
      end

      def actions(&block)
        RailsAdmin::Config::Actions.instance_eval(&block) if block
      end

    end

    # Set default values for configuration options on load
    reset
  end
end
