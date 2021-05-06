module CmAdmin
  module ViewHelpers
    module FormFieldHelper
      def input_field_for_column(f, field)
        case field.type
        when :integer
          return f.number_field field.name, class: 'normal-input'
        when :string
          return f.text_field field.name, class: 'normal-input'
        when :text
          return f.text_area field.name, class: 'normal-input'
        end
      end
    end
  end
end
