module CmAdmin
  module ViewHelpers
    module FieldDisplayHelper
      def show_field(ar_object, field)
        content_tag(:div, class: "info-split") do
          concat show_field_label(ar_object, field)
          concat value_with_prefix_and_suffix(ar_object, field)
        end
      end

      def show_field_label(ar_object, field)
        content_tag(:div, class: "info-split__lhs") do
          p = field.label.present? ? field.label.to_s : field.field_name.to_s.titleize
        end
      end

      def value_with_prefix_and_suffix(ar_object, field)
        value = show_field_value(ar_object, field)
        content_tag(:div, class: "info-split__rhs") do
          concat field.prefix
          concat value
          concat field.suffix
        end
      end

      def show_field_value(ar_object, field)
        case field.field_type || :string
        when :integer
          ar_object.send(field.field_name).to_s
        when :decimal
          ar_object.send(field.field_name).to_f.round(field.precision).to_s if ar_object.send(field.field_name)
        when :string
          ar_object.send(field.field_name).to_s
        when :datetime
          self.extend LocalTimeHelper
          local_time(ar_object.send(field.field_name).strftime(field.format || "%d/%m/%Y").to_s) if ar_object.send(field.field_name)
        when :text
          ar_object.send(field.field_name)
        when :custom
          send(field.helper_method, ar_object, field.field_name)
        when :link
          if field.custom_link
            link = field.custom_link
          else
            link = ar_object.send(field.field_name)
          end
          content_tag :a, href: link do
            ar_object.send(field.field_name).to_s
          end
        when :enum
          ar_object.send(field.field_name).to_s.titleize
        when :tag
          tag_class = field.tag_class.dig("#{ar_object.send(field.field_name.to_s)}".to_sym).to_s
          content_tag :span, class: "status-tag #{tag_class}" do
            ar_object.send(field.field_name).to_s.upcase
          end
        when :attachment
          show_attachment_value(ar_object, field)
        when :drawer
          content_tag :div, class: 'd-flex' do
            concat content_tag(:div, ar_object.send(field.field_name).to_s, class: 'text-ellipsis')
            concat content_tag(:div, 'View', class: 'drawer-btn')
          end
        when :image
          content_tag(:div, class: 'd-flex') do
            if ar_object.send(field.field_name).attached?
              image_tag(ar_object.send(field.field_name).url, height: field.height, width: field.height)
            else
              image_tag('https://cm-admin.s3.ap-south-1.amazonaws.com/gem_static_assets/image_not_available.png', height: 50, width: 50)
            end
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
