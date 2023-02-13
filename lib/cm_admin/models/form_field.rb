module CmAdmin
  module Models
    class FormField
      attr_accessor :field_name, :label, :header, :input_type, :collection, :disabled, :helper_method,
                    :placeholder, :display_if, :html_attr, :target, :ajax_url

      VALID_INPUT_TYPES = %i[
        integer decimal string single_select multi_select date date_time text
        single_file_upload multi_file_upload hidden rich_text check_box radio_button
      ].freeze

      def initialize(field_name, input_type, attributes = {})
        @field_name = field_name
        set_default_values
        attributes.each do |key, value|
          self.send("#{key.to_s}=", value)
        end
        self.display_if = lambda { |arg| return true } if self.display_if.nil?
        raise ArgumentError, "Kindly select a valid input type like #{VALID_INPUT_TYPES.sort.to_sentence(last_word_connector: ', or ')} instead of #{self.input_type} for form field #{field_name}" unless VALID_INPUT_TYPES.include?(self.input_type.to_sym)
      end

      def set_default_values
        self.disabled = false
        self.label = self.field_name.to_s.titleize
        self.input_type = :string
        self.placeholder = "Enter #{self.field_name.to_s.downcase.gsub('_', ' ')}"
        self.html_attr = {}
        self.target = {}
      end
    end
  end
end
