module CmAdmin
  module Config
    module Actions
      class << self
        def all(scope = nil, bindings = {})
          if scope.is_a?(Hash)
            bindings = scope
            scope = :all
          end
          scope ||= :all
          init_actions!
          actions = begin
            case scope
            when :all
              @@actions
            when :root
              @@actions.select(&:root?)
            when :collection
              @@actions.select(&:collection?)
            when :bulkable
              @@actions.select(&:bulkable?)
            when :member
              @@actions.select(&:member?)
            end
          end
        end

        private

        def init_actions!
          @@actions ||= CmAdmin::DEFAULT_ACTIONS
        end
      end
    end
  end
end
