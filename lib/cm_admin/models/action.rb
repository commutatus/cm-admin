require_relative 'actions/blocks'

module CmAdmin
  module Models
    class Action
      include Actions::Blocks
      attr_accessor :name, :verb, :layout_type, :layout, :partial, :path, :page_title, :page_description, :child_records, :is_nested_field, :nested_table_name

      def initialize(attributes = {})
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
      end

      def set_default_values
        self.is_nested_field = false
      end

      class << self
        def find_by(model, search_hash)
          model.available_actions.find { |i| i.name == search_hash[:name] }
        end
      end
    end
  end
end
