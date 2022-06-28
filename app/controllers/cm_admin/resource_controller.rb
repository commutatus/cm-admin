module CmAdmin
  class ResourceController < ApplicationController
    include Pundit::Authorization
    include Pagy::Backend

    def cm_index(params)
      @current_action = CmAdmin::Models::Action.find_by(@model, name: 'index')
      # Based on the params the filter and pagination object to be set
      @ar_object = filter_by(params, nil, filter_params(params))
      # resource_identifier
      respond_to do |format|
        if request.xhr?
          format.html { render partial: '/cm_admin/main/table' }
        else
          format.html { render '/cm_admin/main/' + action_name }
        end
      end
    end

    def cm_show(params)
      @current_action = CmAdmin::Models::Action.find_by(@model, name: 'show')
      scoped_model = "CmAdmin::#{@model.name}Policy::Scope".constantize.new(Current.user, @model.name.constantize).resolve
      @ar_object = scoped_model.find(params[:id])
      resource_identifier
      respond_to do |format|
        format.html { render '/cm_admin/main/' + action_name }
      end
    end

    def cm_new(params)
      @current_action = CmAdmin::Models::Action.find_by(@model, name: 'new')
      @ar_object = @model.ar_model.new
      resource_identifier
      respond_to do |format|
        format.html { render '/cm_admin/main/' + action_name }
      end
    end

    def cm_edit(params)
      @current_action = CmAdmin::Models::Action.find_by(@model, name: 'edit')
      @ar_object = @model.ar_model.name.classify.constantize.find(params[:id])
      resource_identifier
      respond_to do |format|
        format.html { render '/cm_admin/main/' + action_name }
      end
    end

    def cm_update(params)
      @ar_object = @model.ar_model.name.classify.constantize.find(params[:id])
      @ar_object.assign_attributes(resource_params(params))
      resource_identifier
      resource_responder
    end

    def cm_create(params)
      @ar_object = @model.ar_model.name.classify.constantize.new(resource_params(params))
      resource_identifier
      resource_responder
    end

    def cm_custom_method(params)
      scoped_model = "CmAdmin::#{@model.name}Policy::Scope".constantize.new(Current.user, @model.name.constantize).resolve
      resource_identifier
      respond_to do |format|
        if @action.action_type == :custom
          if @action.child_records
            format.html { render @action.layout }
          elsif @action.display_type == :page
            data = @action.parent == "index" ? @ar_object.data : @ar_object
            format.html { render @action.partial }
          else
            ar_object = @action.code_block.call(@ar_object)
            if ar_object.errors.empty?
              redirect_url = @model.current_action.redirection_url || @action.redirection_url || request.referrer || "/cm_admin/#{@model.ar_model.table_name}/#{@ar_object.id}"
              format.html { redirect_to redirect_url, notice: "#{@action.name.titleize} is successful" }
            else
              error_messages = ar_object.errors.full_messages.map{|error_message| "<li>#{error_message}</li>"}.join
              format.html { redirect_to request.referrer, alert: "<b>#{@action.name.titleize} is unsuccessful</b><br /><ul>#{error_messages}</ul>" }
            end
          end
        end
      end
    end

    def resource_identifier
      @ar_object, @associated_model, @associated_ar_object = custom_controller_action(action_name, params.permit!) if !@ar_object.present? && params[:id].present?
      authorize controller_name.classify.constantize, policy_class: "CmAdmin::#{controller_name.classify}Policy".constantize if defined? "CmAdmin::#{controller_name.classify}Policy".constantize
      aar_model = request.url.split('/')[-2].classify.constantize  if params[:aar_id]
      @associated_ar_object = aar_model.find(params[:aar_id]) if params[:aar_id]
      nested_tables = @model.available_fields[:new].except(:fields).keys
      nested_tables += @model.available_fields[:edit].except(:fields).keys
      @reflections = @model.ar_model.reflect_on_all_associations
      nested_tables.each do |table_name|
        reflection = @reflections.select {|x| x if x.name == table_name}.first
        if reflection.macro == :has_many
          @ar_object.send(table_name).build if action_name == "new" || action_name == "edit"
        else
          @ar_object.send(('build_' + table_name.to_s).to_sym) if action_name == "new"
        end
      end
    end

    def resource_responder
      respond_to do |format|
        if params["referrer"]
          redirect_url = params["referrer"]
        else
          redirect_url = CmAdmin::Engine.mount_path + "/#{@model.name.underscore.pluralize}/#{@ar_object.id}"
        end
        if @ar_object.save
          format.html { redirect_to  redirect_url, notice: "#{action_name.titleize} #{@ar_object.class.name.downcase} is successful" }
        else
          format.html { render '/cm_admin/main/new', notice: "#{action_name.titleize} #{@ar_object.class.name.downcase} is unsuccessful" }
        end
      end
    end

    def custom_controller_action(action_name, params)
      current_action = CmAdmin::Models::Action.find_by(@model, name: action_name.to_s)
      if current_action
        @current_action = current_action
        @ar_object = @model.ar_model.name.classify.constantize.find(params[:id])
        if @current_action.child_records
          child_records = @ar_object.send(@current_action.child_records)
          @associated_model = CmAdmin::Model.find_by(name: @model.ar_model.reflect_on_association(@current_action.child_records).klass.name)
          if child_records.is_a? ActiveRecord::Relation
            @associated_ar_object = filter_by(params, child_records)
          else
            @associated_ar_object = child_records
          end
          return @ar_object, @associated_model, @associated_ar_object
        end
        return @ar_object
      end
    end

    def filter_params(params)
      # OPTIMIZE: Need to check if we can permit the filter_params in a better way
      date_columns = @model.filters.select{|x| x.filter_type.eql?(:date)}.map(&:db_column_name)
      range_columns = @model.filters.select{|x| x.filter_type.eql?(:range)}.map(&:db_column_name)
      single_select_columns = @model.filters.select{|x| x.filter_type.eql?(:single_select)}.map(&:db_column_name)
      multi_select_columns = @model.filters.select{|x| x.filter_type.eql?(:multi_select)}.map{|x| Hash["#{x.db_column_name}", []]}

      params.require(:filters).permit(:search, date: date_columns, range: range_columns, single_select: single_select_columns, multi_select: multi_select_columns) if params[:filters]
    end

    def filter_by(params, records, filter_params={}, sort_params={})
      filtered_result = OpenStruct.new
      sort_column = "created_at"
      sort_direction = %w[asc desc].include?(sort_params[:sort_direction]) ? sort_params[:sort_direction] : "asc"
      sort_params = {sort_column: sort_column, sort_direction: sort_direction}
      
      records = "CmAdmin::#{@model.name}Policy::Scope".constantize.new(Current.user, @model.name.constantize).resolve if records.nil?
      records = records.order("#{@current_action.sort_column} #{@current_action.sort_direction}")

      final_data = CmAdmin::Models::Filter.filtered_data(filter_params, records, @model.filters)
      pagy, records = pagy(final_data)
      filtered_result.data = records
      filtered_result.pagy = pagy
      # filtered_result.facets = paginate(page, raw_data.size)
      # filtered_result.sort = sort_params
      # filtered_result.facets.sort = sort_params
      return filtered_result
    end

    def resource_params(params)
      permittable_fields = @permitted_fields || @model.ar_model.columns.map(&:name).reject { |i| CmAdmin::REJECTABLE_FIELDS.include?(i) }.map(&:to_sym)
      permittable_fields += @model.ar_model.name.constantize.reflect_on_all_associations.map {|x|
        next if x.options[:polymorphic]
        # The first if statement is added for compatibilty with cm-page-builder.
        # One of the associated models of cm-page-builder was throwing error.
        # The associated model is CmPageBuilder::Rails::PageComponent.
        # When using reflection, the value of klass of the above association is uninitialized.
        # As a result, it was throwing error in the 2nd elsif statement.
        if x.name == :page_components
          x.name
        elsif x.klass.name == "ActiveStorage::Attachment"
          if x.class.name.include?('HasOne')
            x.name
          elsif x.class.name.include?('HasMany')
            Hash[x.name.to_s, []]
          end
        elsif x.klass.name == "ActionText::RichText"
          x.name.to_s.gsub('rich_text_', '').to_sym
        end
      }.compact
      nested_tables = @model.available_fields[:new].except(:fields).keys
      nested_tables += @model.available_fields[:edit].except(:fields).keys
      nested_fields = nested_tables.uniq.map {|table|
        Hash[
          table.to_s + '_attributes',
          table.to_s.classify.constantize.columns.map(&:name).reject { |i| CmAdmin::REJECTABLE_FIELDS.include?(i) }.map(&:to_sym) + [:id, :_destroy]
        ]
      }
      permittable_fields += nested_fields
      @model.ar_model.columns.map { |col| permittable_fields << col.name.split('_cents') if col.name.include?('_cents') }

      params.require(@model.name.underscore.to_sym).permit(*permittable_fields)
    end

  end
end
