module CmAdmin
  module ViewHelpers
    module ShowFieldHelper

      def show_field(ar_object, field)
        content_tag(:div, class: "info-split") do
          concat show_field_label(ar_object, field)
          concat show_field_value(ar_object, field)
        end
      end

      def show_field_label(ar_object, field)
        content_tag(:div, class: "info-split__lhs") do
          p = field.label.present? ? field.label.to_s : field.field_name.to_s.titleize
        end
      end
      
      def show_field_value(ar_object, field)
        content_tag(:div, class: "info-split__lhs") do
          case field.field_type
          when :integer
            ar_object.send(field.field_name).to_s
          when :decimal
            ar_object.send(field.field_name).to_f.to_s
          when :string
            ar_object.send(field.field_name)
          when :datetime
            ar_object.send(field.field_name).strftime(field.format || "%d/%m/%Y").to_s
          when :text
            ar_object.send(field.field_name)
          when :link
            content_tag :a, href: ar_object.send(field.field_name) do
              ar_object.send(field.field_name).to_s
            end 
          when :attachment
            concat show_attachment_value(ar_object, field)
          end
        end
      end

      def show_attachment_value(ar_object, field)
        if ar_object.send(field.field_name).attached?
          if ar_object.send(field.field_name).class.name.include?('One')
            content_tag :a, href: rails_blob_path(ar_object.send(field.field_name), disposition: "attachment") do
              ar_object.send(field.field_name).filename.to_s 
            end
          elsif ar_object.send(field.field_name).class.name.include?('Many')
            ar_object.send(field.field_name).map do |asset|
              content_tag :a, href: rails_blob_path(asset, disposition: "attachment") do
                asset.filename.to_s 
              end
            end.join("\n").html_safe
          end
        end
      end
    end
  end
end
