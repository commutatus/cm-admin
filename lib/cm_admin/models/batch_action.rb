require_relative 'actions/blocks'

module CmAdmin
  module Models
    class BulkAction < Action
      include Actions::Blocks

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