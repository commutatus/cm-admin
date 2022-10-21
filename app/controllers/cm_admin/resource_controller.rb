module CmAdmin
  class ResourceController < ApplicationController
    include Pundit::Authorization
    include Pagy::Backend

    helper CmAdmin::ViewHelpers

    def cm_index(params)
      @current_action = CmAdmin::Models::Action.find_by(@model, name: 'index')
      # Based on the params the filter and pagination object to be set
      @ar_object = filter_by(params, nil, @model.filter_params(params))
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

    def cm_custom_method(params)
      scoped_model = "CmAdmin::#{@model.name}Policy::Scope".constantize.new(Current.user, @model.name.constantize).resolve
      resource_identifier
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
      current_action = CmAdmin::Models::Action.find_by(@model, name: action_name.to_s)
      if current_action
        @current_action = current_action
        @ar_object = @model.ar_model.name.classify.constantize.find(params[:id])
        if @current_action.child_records
          child_records = @ar_object.send(@current_action.child_records)
          @associated_model = CmAdmin::Model.find_by(name: @model.ar_model.reflect_on_association(@current_action.child_records).klass.name)
          if child_records.is_a? ActiveRecord::Relation
            @associated_ar_object = filter_by(params, child_records, @associated_model.filter_params(params))
          else
            @associated_ar_object = child_records
          end
          return @ar_object, @associated_model, @associated_ar_object
        end
        return @ar_object
      end
    end

    def filter_by(params, records, filter_params={}, sort_params={})
      filtered_result = OpenStruct.new
      sort_column = "created_at"
      sort_direction = %w[asc desc].include?(sort_params[:sort_direction]) ? sort_params[:sort_direction] : "asc"
      sort_params = {sort_column: sort_column, sort_direction: sort_direction}
      
      records = "CmAdmin::#{@model.name}Policy::Scope".constantize.new(Current.user, @model.name.constantize).resolve if records.nil?
      records = records.order("#{@current_action.sort_column} #{@current_action.sort_direction}")
      final_data = CmAdmin::Models::Filter.filtered_data(filter_params, records, @associated_model ? @associated_model.filters : @model.filters)
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
        if x.class.name.include?('HasOne')
          x.name.to_s.gsub('_attachment', '').gsub('rich_text_', '').to_sym
        elsif x.class.name.include?('HasMany')
          Hash[x.name.to_s.gsub('_attachment', ''), []]
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
