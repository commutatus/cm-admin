require_relative 'actions/blocks'

module CmAdmin
  module Models
    class Action
      include Actions::Blocks
      attr_accessor :name, :verb, :layout, :partial

      def initialize(attributes = {})
        attributes.each do |key, value|
          self.send("#{key.to_s}=", value)
        end
      end

      class << self
        def find_by(model, search_hash)
          model.available_actions.find { |i| i.name == search_hash[:name] }
        end
      end
    end
  end
end
