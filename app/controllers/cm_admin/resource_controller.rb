module CmAdmin
  class ResourceController < ApplicationController
    include Pundit::Authorization
    include Pagy::Backend

    helper CmAdmin::ViewHelpers

    def cm_index(params)
      @current_action = CmAdmin::Models::Action.find_by(@model, name: 'index')
      # Based on the params the filter and pagination object to be set
      records = "CmAdmin::#{@model.name}Policy::Scope".constantize.new(Current.user, @model.name.constantize).resolve
      records = apply_scopes(records)
      @ar_object = filter_by(params, records, @model.filter_params(params))
      managed_column = ManagedColumn.where(user_id: Current.user.id, table_name: @model.name.underscore).first
      if managed_column.present? && managed_column.arranged_columns&.dig("column_list")&.map{|column_hash| column_hash['is_enabled'] }.include?(true)
        @selected_columns = managed_column.arranged_columns.dig("column_list").map { |column_hash|
          @model.available_fields[:index].select{ |field| field.field_name.to_s == column_hash['column_name'] && column_hash['is_enabled']  }
        }.flatten
        @ordered_columns = managed_column.arranged_columns.dig("column_list").map { |column_hash|
          @model.available_fields[:index].select{ |field| field.field_name.to_s == column_hash['column_name']}
        }.flatten
      else
        @selected_columns = @model.available_fields[:index]
        @ordered_columns = @model.available_fields[:index]
      end
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

    def cm_destroy(params)
      @ar_object = @model.ar_model.name.classify.constantize.find(params[:id])
      redirect_url = request.referrer || cm_admin.send("#{@model.name.underscore}_index_path")
      respond_to do |format|
        if @ar_object.destroy
          format.html { redirect_back fallback_location: redirect_url, notice: "#{action_name.titleize} #{@ar_object.class.name.downcase} is successful" }
        else
          format.html { redirect_back fallback_location: redirect_url, notice: "#{action_name.titleize} #{@ar_object.class.name.downcase} is unsuccessful" }
        end
      end
    end

    def import
      @model = Model.find_by({name: controller_name.titleize})
      allowed_params = params.permit(file_import: [:associated_model_name, :import_file]).to_h
      file_import = ::FileImport.new(allowed_params[:file_import])
      file_import.added_by = Current.user
      respond_to do |format|
        if file_import.save!
          format.html { redirect_back fallback_location: cm_admin.send("#{@model.name.underscore}_index_path"), notice: "Your import is successfully queued." }
        end
      end
    end

    def import_form
      @model = Model.find_by({name: controller_name.titleize})
      respond_to do |format|
        format.html { render '/cm_admin/main/import_form' }
      end
    end

    def manage_column
      managed_column = ManagedColumn.where(user_id: Current.user.id, table_name: params[:managed_column][:table_name]).first_or_initialize
      sorted_columns_arr = []
      params[:managed_column][:sorted_columns].each do |column_name|
        sorted_columns_arr << {
          column_name: column_name,
          is_enabled: params[:managed_column][:enabled_columns]&.include?(column_name)
        }
      end
      managed_column.arranged_columns = {
        column_list: sorted_columns_arr
      }
      respond_to do |format|
        if managed_column.save!
          format.html { redirect_back fallback_location: cm_admin.send("#{managed_column.table_name}_index_path"), notice: "Your setting is successfully saved." }
        else
          format.html { redirect_back fallback_location: cm_admin.send("#{managed_column.table_name}_index_path"), alert: "Your setting is not saved." }
        end
      end
    end

    def cm_history(params)
      @current_action = CmAdmin::Models::Action.find_by(@model, name: 'history')
      resource_identifier
      respond_to do |format|
        format.html { render '/cm_admin/main/history' }
      end
    end

    def cm_custom_method(params)
      records = "CmAdmin::#{@model.name}Policy::Scope".constantize.new(Current.user, @model.name.constantize).resolve
      @current_action = @action
      if  @action.parent == 'index'
        records = apply_scopes(records)
        @ar_object = filter_by(params, records, @model.filter_params(params))
      else
        resource_identifier
      end
      respond_to do |format|
        if @action.action_type == :custom
          if @action.child_records
            if request.xhr?
              format.html { render partial: '/cm_admin/main/associated_table' }
            else
              format.html { render @action.layout }
            end
          elsif @action.display_type == :page
            data = @action.parent == "index" ? @ar_object.data : @ar_object
            format.html { render @action.partial }
          else
            response_object = @action.code_block.call(@response_object)
            if response_object.class == Hash
              format.json { render json: response_object }
            elsif response_object.errors.empty?
              redirect_url = @model.current_action.redirection_url || @action.redirection_url || request.referrer || "/cm_admin/#{@model.ar_model.table_name}/#{@response_object.id}"
              format.html { redirect_to redirect_url, notice: "#{@action.name.titleize} is successful" }
            else
              error_messages = response_object.errors.full_messages.map{|error_message| "<li>#{error_message}</li>"}.join
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
      nested_tables = @model.available_fields[:new].map(&:nested_table_fields).map(&:keys).flatten
      nested_tables += @model.available_fields[:edit].map(&:nested_table_fields).map(&:keys).flatten
      @reflections = @model.ar_model.reflect_on_all_associations
      nested_tables.each do |table_name|
        reflection = @reflections.select {|x| x if x.name == table_name}.first
        if reflection.macro == :has_many
          @ar_object.send(table_name).build if action_name == "new" || action_name == "edit"
        elsif action_name == "new"
          @ar_object.send(('build_' + table_name.to_s).to_sym)
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
      @current_action = CmAdmin::Models::Action.find_by(@model, name: action_name.to_s)
      return unless @current_action

      @ar_object = @model.ar_model.name.classify.constantize.find(params[:id])
      return @ar_object unless @current_action.child_records

      child_records = @ar_object.send(@current_action.child_records)
      child_records = apply_scopes(child_records)
      @reflection = @model.ar_model.reflect_on_association(@current_action.child_records)
      @associated_model = if @reflection.klass.column_names.include?('type')
                            CmAdmin::Model.find_by(name: @reflection.plural_name.classify)
                          else
                            CmAdmin::Model.find_by(name: @reflection.klass.name)
                          end
      @associated_ar_object = if child_records.is_a? ActiveRecord::Relation
                                filter_by(params, child_records, @associated_model.filter_params(params))
                              else
                                child_records
                              end
      return @ar_object, @associated_model, @associated_ar_object
    end

    def apply_scopes(records)
      @current_action.scopes.each do |scope|
        records = records.send(scope)
      end
      records
    end

    def filter_by(params, records, filter_params={}, sort_params={})
      filtered_result = OpenStruct.new
      cm_model = @associated_model || @model
      db_columns = cm_model.ar_model&.columns&.map{|x| x.name.to_sym}
      if db_columns.include?(@current_action.sort_column)
        sort_column = @current_action.sort_column
      else
        sort_column = 'created_at'
      end
      records = "CmAdmin::#{@model.name}Policy::Scope".constantize.new(Current.user, @model.name.constantize).resolve if records.nil?
      records = records.order("#{sort_column} #{@current_action.sort_direction}")
      final_data = CmAdmin::Models::Filter.filtered_data(filter_params, records, cm_model.filters)
      pagy, records = pagy(final_data)
      filtered_result.data = records
      filtered_result.pagy = pagy
      # filtered_result.facets = paginate(page, raw_data.size)
      # filtered_result.sort = sort_params
      # filtered_result.facets.sort = sort_params
      return filtered_result
    end

    def resource_params(params)
      columns = @model.ar_model.columns_hash.map {|key, ar_adapter|
        ar_adapter.sql_type_metadata.sql_type.ends_with?('[]') ? Hash[ar_adapter.name, []] : ar_adapter.name.to_sym
      }
      columns += @model.ar_model.stored_attributes.values.flatten
      permittable_fields = @model.additional_permitted_fields + columns.reject { |i| CmAdmin::REJECTABLE_FIELDS.include?(i) }
      permittable_fields += @model.ar_model.name.constantize.reflect_on_all_associations.map {|x|
        next if x.options[:polymorphic]
        if x.class.name.include?('HasOne')
          x.name.to_s.gsub('_attachment', '').gsub('rich_text_', '').to_sym
        elsif x.class.name.include?('HasMany')
          Hash[x.name.to_s.gsub('_attachments', ''), []]
        end
      }.compact
      nested_tables = @model.available_fields[:new].map(&:nested_table_fields).map(&:keys).flatten
      nested_tables += @model.available_fields[:edit].map(&:nested_table_fields).map(&:keys).flatten
      nested_fields = nested_tables.uniq.map {|table|
        Hash[
          table.to_s + '_attributes',
          table.to_s.classify.constantize.column_names.reject { |i| CmAdmin::REJECTABLE_FIELDS.include?(i) }.map(&:to_sym) + [:id, :_destroy]
        ]
      }
      permittable_fields += nested_fields
      @model.ar_model.columns.map { |col| permittable_fields << col.name.split('_cents') if col.name.include?('_cents') }
      params.require(@model.name.underscore.to_sym).permit(*permittable_fields)
    end

  end
end
