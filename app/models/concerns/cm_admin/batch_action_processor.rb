class CmAdmin::BatchActionProcessor
  extend ActiveSupport::Concern
  attr_accessor :invalid_records

  def initialize(current_action, model, params)
    @invalid_records = []
    @current_action = current_action
    @model = model
    @params = params
  end

  def perform_batch_action
    @params[:selected_ids].each do |id|
      ar_object = @model.ar_model.find(id)
      column_name = @model.available_fields[:index].first.field_name
      begin
        @current_action.code_block.call(id)
      rescue => exception
        case exception.class.name
        when "NoMethodError"
          @invalid_records << OpenStruct.new({row_identifier: ar_object.send(column_name), error_message: exception.message.slice(0..(exception.message.index(' for'))) + " at #{ar_object.send(column_name)}" })
        when "ActiveRecord::RecordInvalid"
          @invalid_records << OpenStruct.new({row_identifier: ar_object.send(column_name), error_message: exception.message + " at #{ar_object.send(column_name)}" })
        else
          @invalid_records << OpenStruct.new({row_identifier: ar_object.send(column_name), error_message: exception.message })
        end
      end
    end
    self
  end
end
