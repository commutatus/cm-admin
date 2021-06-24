module CmAdmin
  module Models
    class FormField
      attr_accessor :field_name, :label, :header, :input_type, :collection
      VALID_INPUT_TYPES = [:integer, :decimal, :string, :single_select, :multi_select, :date, :date_time, :text, :single_file_upload, :multi_file_upload].freeze

      def initialize(field_name, input_type, attributes = {})
        raise ArgumentError, "Kindly select a valid filter type like #{VALID_INPUT_TYPES.sort.to_sentence(last_word_connector: ', or ')} instead of #{input_type} for column #{field_name}" unless VALID_INPUT_TYPES.include?(input_type.to_sym)
        @field_name = field_name
        attributes.each do |key, value|
          self.send("#{key.to_s}=", value)
        end
      end
    end
  end
end
