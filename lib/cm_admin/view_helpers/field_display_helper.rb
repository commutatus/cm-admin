module CmAdmin
  module ViewHelpers
    module FieldDisplayHelper
      def show_field(ar_object, field)
        return unless field.display_if.call(ar_object)
        content_tag(:div, class: "card-info") do
          concat show_field_label(ar_object, field)
          concat value_with_prefix_and_suffix(ar_object, field)
        end
      end

      def show_rows(ar_object, rows, col_size: 3)
        rows.map do |row|
          content_tag(:div, class: 'row') do
            row.row_fields.map do |field|
              next unless field.display_if.call(ar_object)

              content_tag(:div, class: "col-#{col_size}") do
                content_tag(:div, class: "card-info") do
                  concat show_field_label(ar_object, field)
                  concat value_with_prefix_and_suffix(ar_object, field)
                end
              end
            end.compact.join.html_safe
          end
        end.join.html_safe
      end

      def show_field_label(ar_object, field)
        content_tag(:div, class: "card-info__label") do
          field_label = if field.label.present?
                          field.label.to_s
                        elsif field.association_type.to_s == "polymorphic"
                          ar_object.send(field.association_name).class.to_s.titleize
                        else
                          field.field_name.to_s.titleize
                        end
          p = field_label
        end
      end

      def value_with_prefix_and_suffix(ar_object, field)
        value = show_field_value(ar_object, field)
        content_tag(:div, class: "card-info__description") do
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
        when :date
          return unless ar_object.send(field.field_name)

          self.extend LocalTimeHelper
          local_date(ar_object.send(field.field_name), (field.format || '%B %e, %Y'))
        when :text
          ar_object.send(field.field_name)
        when :rich_text
          sanitize ar_object.send(field.field_name)
        when :money
          humanized_money(ar_object.send(field.field_name))
        when :money_with_symbol
          humanized_money_with_symbol(ar_object.send(field.field_name))
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
            ar_object.send(field.field_name).to_s.titleize.upcase
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
              if has_one_image_attached?(ar_object, field)
                content_tag :a, href: rails_blob_path(ar_object.send(field.field_name)), target: '_blank' do
                  image_tag(ar_object.send(field.field_name).url, height: field.height, width: field.width, class: 'rounded')
                end
              elsif has_many_image_attached?(ar_object, field)
                ar_object.send(field.field_name).map do |asset|
                  content_tag :a, href: rails_blob_path(asset), target: '_blank' do
                    image_tag(asset.url, height: field.height, width: field.width, class: 'rounded mr-1')
                  end
                end.join("\n").html_safe
              end
            else
              image_tag('https://cm-admin.s3.ap-south-1.amazonaws.com/gem_static_assets/image_not_available.png', height: 50, width: 50)
            end
          end
        when :association
          if field.association_type.to_s == 'polymorphic'
            association_name = ar_object.send(field.association_name).class.to_s.underscore
            field_name = find_field_name(field, association_name)
            link_to ar_object.send(field.association_name).send(field_name), cm_admin.send("#{association_name}_show_path", ar_object.send(field.association_name))
          elsif ['belongs_to', 'has_one'].include? field.association_type.to_s
            link_to ar_object.send(field.association_name).send(field.field_name), cm_admin.send("#{field.association_name}_show_path", ar_object.send(field.association_name))
          end
        end
      end

      def show_attachment_value(ar_object, field)
        if ar_object.send(field.field_name).attached?
          if has_one_image_attached?(ar_object, field)
            content_tag :a, href: rails_blob_path(ar_object.send(field.field_name), disposition: "attachment") do
              ar_object.send(field.field_name).filename.to_s
            end
          elsif has_many_image_attached?(ar_object, field)
            ar_object.send(field.field_name).map do |asset|
              content_tag(:div) do
                content_tag :a, href: rails_blob_path(asset, disposition: "attachment") do
                  asset.filename.to_s
                end
              end
            end.join("\n").html_safe
          end
        end
      end

      def find_field_name(field, association_name)
        field.field_name.each do |hash|
          return hash[association_name.to_sym] if hash.has_key?(association_name.to_sym)
        end
      end

      def has_one_image_attached?(ar_object, field)
        ar_object.send(field.field_name).class.name.include?('One')
      end

      def has_many_image_attached?(ar_object, field)
        ar_object.send(field.field_name).class.name.include?('Many')
      end
    end
  end
end
