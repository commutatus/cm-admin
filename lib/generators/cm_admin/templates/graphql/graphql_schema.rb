class <%= Rails.application.class.module_parent_name %>Schema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)

  # Union and Interface Resolution
  def self.resolve_type(abstract_type, obj, ctx)
    # TODO: Implement this function
    # to return the correct object type for `obj`
    raise(GraphQL::RequiredImplementationMissingError)
  end

  # Relay-style Object Identification:

  # Return a string UUID for `object`
  def self.id_from_object(object, type_definition, query_ctx)
    # Here's a simple implementation which:
    # - joins the type name & object.id
    # - encodes it with base64:
    # GraphQL::Schema::UniqueWithinType.encode(type_definition.name, object.id)
  end

  # Given a string UUID, find the object
  def self.object_from_id(id, query_ctx)
    # For example, to decode the UUIDs generated above:
    # type_name, item_id = GraphQL::Schema::UniqueWithinType.decode(id)
    #
    # Then, based on `type_name` and `id`
    # find an object in your application
    # ...
  end

  rescue_from ActiveRecord::RecordNotFound do |err, obj, args, ctx, field|
    GraphQL::ExecutionError.new("#{field.type.unwrap.graphql_name} not found", extensions: {code: :unprocessable_entity, sub_code: :record_invalid, message: err.message})
  end

  rescue_from ActiveRecord::RecordInvalid do |err, obj, args, ctx, field|
    GraphQL::ExecutionError.new(err.message, extensions: {code: :unprocessable_entity, sub_code: :record_invalid, message: err.message})
  end

  rescue_from BaseException do |err, obj, args, ctx, field|
    GraphQL::ExecutionError.new(err.message, extensions: {code: err.code, sub_code: err.sub_code, message: err.message})
  end

  unless Rails.env.development?
	  rescue_from StandardError do |err, obj, args, ctx, field|
      rollbar_error = Rollbar.error(err)
	    GraphQL::ExecutionError.new("Internal Server Error", extensions: {code: :internal_server_error, uuid: rollbar_error[:uuid]})
	  end
	end

  def self.unauthorized_object(error)
    raise Unauthorized, I18n.t("graphql.unauthorized", error_type: error.type.graphql_name)
  end
  
end