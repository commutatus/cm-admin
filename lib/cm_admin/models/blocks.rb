module CmAdmin
  module Models
    module Blocks
      extend ActiveSupport::Concern

      included do
        attr_accessor :menu, :title
      end

      def set_menu(state)
        self.menu = state.to_s == 'on' ? true : false
      end

      def set_title(name)
        self.title = name
      end
    end
  end
end
