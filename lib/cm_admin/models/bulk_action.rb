require_relative 'actions/blocks'

module CmAdmin
  module Models
    class BulkAction < Action
      attr_accessor :modal_configuration

      def initialize(attributes = {}, &block)
        super
        override_default_values
      end

      def override_default_values
        self.icon_name = 'fa fa-layer-group'
        self.verb = :post
      end
    end
  end
end