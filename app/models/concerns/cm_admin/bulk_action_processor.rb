class CmAdmin::BulkActionProcessor
  extend ActiveSupport::Concern
  attr_accessor :invalid_records

  def initialize(current_action, model, params)
    @invalid_records = []
    @current_action = current_action
    @model = model
    @params = params
  end

  def perform_bulk_action
    @params[:selected_ids].split(',').each do |id|
      ar_object = @model.ar_model.find(id)
      column_name = @model.available_fields[:index].first.field_name
      begin
        @current_action.code_block.call(id)
        @error_message = nil
      rescue NoMethodError, NameError => e
        @error_message = "#{e.message.slice(0..(e.message.index(' for')))} at #{ar_object.send(column_name)}"
      rescue ActiveRecord::RecordInvalid => e
        @error_message = "#{e.message} at #{ar_object.send(column_name)}"
      rescue StandardError => e
        @error_message = "#{ar_object.send(column_name)} - #{e.message}"
      end
      @invalid_records << OpenStruct.new({ row_identifier: ar_object.send(column_name), error_message: @error_message }) if @error_message
    end
    self
  end
end
