require_relative 'actions/blocks'

module CmAdmin
  module Models
    class CustomAction < Action
      attr_accessor :modal_configuration, :url_params

      def initialize(attributes = {}, &block)
        super
      end

      class << self
        def find_by(model, search_hash)
          model.available_actions.find { |i| i.name == search_hash[:name] }
        end
      end
    end
  end
end
