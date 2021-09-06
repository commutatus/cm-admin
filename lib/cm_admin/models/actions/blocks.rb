module CmAdmin
  module Models
    module Actions
      module Blocks
        extend ActiveSupport::Concern

        included do
          attr_accessor :title
        end

        def set_layout(name)
          self.layout = name
        end

        def set_partial(name)
          self.partial = name
        end

        def set_title(name)
          self.title = name
        end
      end
    end
  end
end
