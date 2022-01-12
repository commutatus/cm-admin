require_relative 'actions/blocks'

module CmAdmin
  module Models
    class Action
      include Actions::Blocks
      attr_accessor :name, :verb, :layout_type, :layout, :partial, :path, :page_title, :page_description,
        :child_records, :is_nested_field, :nested_table_name, :parent, :display_if, :route_type, :code_block,
        :display_type, :action_type

      def initialize(attributes = {}, &block)
        if attributes[:layout_type].present? && attributes[:layout].nil? && attributes[:partial].nil?
          case attributes[:layout_type]
          when 'cm_association_index'
            attributes[:layout] = '/cm_admin/main/associated_index'
            attributes[:partial] = '/cm_admin/main/associated_table'
          when 'cm_association_show'
            attributes[:layout] = '/cm_admin/main/associated_show'
          end
        end
        set_default_values
        attributes.each do |key, value|
          self.send("#{key.to_s}=", value)
        end
        self.send("code_block=", block) if block_given?
      end

      def set_default_values
        self.is_nested_field = false
        self.display_if = lambda { |arg| return true }
        self.display_type = :button
        self.action_type = :default
      end

      class << self
        def find_by(model, search_hash)
          model.available_actions.find { |i| i.name == search_hash[:name] }
        end
      end
    end
  end
end
