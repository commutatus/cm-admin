require_relative 'actions/blocks'

module CmAdmin
  module Models
    class BatchAction
      include Actions::Blocks
      attr_accessor :name, :display_name, :display_if, :redirection_url, :icon_name

      def initialize(attributes = {}, &block)
        set_default_values
        attributes.each do |key, value|
          send("#{key}=", value)
        end
      end

      def set_default_values
        self.display_if = lambda { |_arg| return true }
        self.icon_name = 'fa fa-th-large'
      end
    end
  end
end