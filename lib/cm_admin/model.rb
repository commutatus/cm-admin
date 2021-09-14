require_relative 'constants'
require_relative 'models/action'
require_relative 'models/field'
require_relative 'models/form_field'
require_relative 'models/blocks'
require_relative 'models/column'
require_relative 'models/filter'
require_relative 'models/export'
require_relative 'models/cm_show_section'
require_relative 'models/tab'
require 'pagy'
require 'axlsx'
require 'cocoon'

module CmAdmin
  class Model
    include Pagy::Backend
    include Models::Blocks
    attr_accessor :available_actions, :actions_set, :available_fields, :permitted_fields, :current_action, :params, :filters, :available_tabs
    attr_reader :name, :ar_model

    # Class variable for storing all actions
    # CmAdmin::Model.all_actions
    singleton_class.send(:attr_accessor, :all_actions)

    def initialize(entity, &block)
      @name = entity.name
      @ar_model = entity
      @available_actions ||= []
      @current_action = nil
      @available_tabs ||= []
      @available_fields ||= {index: [], show: [], edit: {fields: []}, new: {fields: []}}
      @params = nil
      @filters ||= []
      instance_eval(&block) if block_given?
      actions unless @actions_set
      $available_actions = @available_actions.dup
      self.class.all_actions.push(@available_actions)
      define_controller
    end

    class << self
      def all_actions
        @all_actions || []
      end

      def find_by(search_hash)
        CmAdmin.cm_admin_models.find { |x| x.name == search_hash[:name] }
      end
    end

    def custom_controller_action(action_name, params)
      current_action = CmAdmin::Models::Action.find_by(self, name: action_name.to_s)
      if current_action
        @current_action = current_action
        @ar_object = @ar_model.find(params[:id])
        if @current_action.child_records
          child_records = @ar_object.send(@current_action.child_records)
          @associated_model = CmAdmin::Model.find_by(name: @ar_model.reflect_on_association(@current_action.child_records).klass.name)
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

    # Insert into actions according to config block
    def actions(only: [], except: [])
      acts = CmAdmin::DEFAULT_ACTIONS.keys
      acts = acts & (Array.new << only).flatten if only.present?
      acts = acts - (Array.new << except).flatten if except.present?
      acts.each do |act|
        action_defaults = CmAdmin::DEFAULT_ACTIONS[act]
        @available_actions << CmAdmin::Models::Action.new(name: act.to_s, verb: action_defaults[:verb], path: action_defaults[:path])
      end
      @actions_set = true
    end

    def cm_show(page_title: nil,page_description: nil,&block)
      @current_action = CmAdmin::Models::Action.find_by(self, name: 'show')
      @current_action.page_title = page_title
      @current_action.page_description = page_description
      yield
    end

    def cm_edit(page_title: nil,page_description: nil, &block)
      @current_action = CmAdmin::Models::Action.find_by(self, name: 'edit')
      @current_action.page_title = page_title
      @current_action.page_description = page_description
      yield
    end

    def cm_new(page_title: nil,page_description: nil,&block)
      @current_action = CmAdmin::Models::Action.find_by(self, name: 'new')
      @current_action.page_title = page_title
      @current_action.page_description = page_description
      yield
    end

    def cm_index(page_title: nil ,page_description: nil, &block)
      @current_action = CmAdmin::Models::Action.find_by(self, name: 'index')
      @current_action.page_title = page_title
      @current_action.page_description = page_description
      yield
      # action.instance_eval(&block)
    end

    def show(params)
      @current_action = CmAdmin::Models::Action.find_by(self, name: 'show')
      @ar_object = @ar_model.find(params[:id])
    end

    def index(params)
      @current_action = CmAdmin::Models::Action.find_by(self, name: 'index')
      # Based on the params the filter and pagination object to be set
      @ar_object = filter_by(params, nil, filter_params(params))
    end

    def new(params)
      @current_action = CmAdmin::Models::Action.find_by(self, name: 'new')
      @ar_object = @ar_model.new
    end

    def edit(params)
      @current_action = CmAdmin::Models::Action.find_by(self, name: 'edit')
      @ar_object = @ar_model.find(params[:id])
    end

    def update(params)
      @ar_object = @ar_model.find(params[:id])
      @ar_object.assign_attributes(resource_params(params))
      @ar_object
    end

    def create(params)
      @ar_object = @ar_model.new(resource_params(params))
    end


    def filter_by(params, records, filter_params={}, sort_params={})
      filtered_result = OpenStruct.new
      sort_column = "created_at"
      sort_direction = %w[asc desc].include?(sort_params[:sort_direction]) ? sort_params[:sort_direction] : "asc"
      sort_params = {sort_column: sort_column, sort_direction: sort_direction}
      records = self.name.constantize.where(nil) if records.nil?
      final_data = CmAdmin::Models::Filter.filtered_data(filter_params, records, @filters)
      pagy, records = pagy(final_data)
      filtered_result.data = records
      filtered_result.pagy = pagy
      # filtered_result.facets = paginate(page, raw_data.size)
      # filtered_result.sort = sort_params
      # filtered_result.facets.sort = sort_params
      return filtered_result
    end

    def resource_params(params)
      permittable_fields = @permitted_fields || @ar_model.columns.map(&:name).reject { |i| CmAdmin::REJECTABLE_FIELDS.include?(i) }.map(&:to_sym)
      permittable_fields += @ar_model.reflect_on_all_attachments.map {|x|
        if x.class.name.include?('HasOne')
          x.name
        elsif x.class.name.include?('HasMany')
          Hash[x.name.to_s, []]
        end
      }.compact
      nested_tables = self.available_fields[:new].except(:fields).keys
      nested_tables += self.available_fields[:edit].except(:fields).keys
      nested_fields = nested_tables.map {|table|
        Hash[
          table.to_s + '_attributes',
          table.to_s.singularize.titleize.constantize.columns.map(&:name).reject { |i| CmAdmin::REJECTABLE_FIELDS.include?(i) }.map(&:to_sym) + [:id, :_destroy]
        ]
      }
      permittable_fields += nested_fields
      params.require(self.name.underscore.to_sym).permit(*permittable_fields)
    end

    def page_title(title)
      if @current_action
        @current_action.page_title = title
      end
    end

    def page_description(description)
      if @current_action
        @current_action.page_description = description
      end
    end

    def tab(tab_name, custom_action, associated_model: nil, layout_type: nil, layout: nil, partial: nil, &block)
      if custom_action.to_s == ''
        @current_action = CmAdmin::Models::Action.find_by(self, name: 'show')
        @available_tabs << CmAdmin::Models::Tab.new(tab_name, '', &block)
      else
        action = CmAdmin::Models::Action.new(name: custom_action.to_s, verb: :get, path: ':id/'+custom_action, layout_type: layout_type, layout: layout, partial: partial, child_records: associated_model)
        @available_actions << action
        @current_action = action
        @available_tabs << CmAdmin::Models::Tab.new(tab_name, custom_action, &block)
      end
      yield if block
    end

    def cm_show_section(section_name, &block)
      @available_fields[@current_action.name.to_sym] ||= []
      @available_fields[@current_action.name.to_sym] << CmAdmin::Models::CmShowSection.new(section_name, &block)
    end

    def form_field(field_name, options={}, arg=nil)
      unless @current_action.is_nested_field
        @available_fields[@current_action.name.to_sym][:fields] << CmAdmin::Models::FormField.new(field_name, options[:input_type], options)
      else
        @available_fields[@current_action.name.to_sym][@current_action.nested_table_name] ||= []
        @available_fields[@current_action.name.to_sym][@current_action.nested_table_name] << CmAdmin::Models::FormField.new(field_name, options[:input_type], options)
      end
    end

    def nested_form_field(field_name, &block)
      @current_action.is_nested_field = true
      @current_action.nested_table_name = field_name
      yield
    end

    def column(field_name, options={})
      @available_fields[@current_action.name.to_sym] ||= []
      unless @available_fields[@current_action.name.to_sym].map{|x| x.field_name.to_sym}.include?(field_name)
        @available_fields[@current_action.name.to_sym] << CmAdmin::Models::Column.new(field_name, options)
      end
      if @available_fields[@current_action.name.to_sym].select{|x| x.lockable}.size > 0 && options[:lockable]
      end
      unless @available_fields[@current_action.name.to_sym].map{|x| x.field_name.to_sym}.include?(field_name)
        @available_fields[@current_action.name.to_sym] << CmAdmin::Models::Column.new(field_name, options)
      end
    end

    def all_db_columns(options={})
      field_names = self.instance_variable_get(:@ar_model)&.columns&.map{|x| x.name.to_sym}
      if options.include?(:exclude) && field_names
        excluded_fields = (Array.new << options[:exclude]).flatten.map(&:to_sym)
        field_names -= excluded_fields
      end
      field_names.each do |field_name|
        column field_name
      end
    end

    # Custom actions
    # eg
    # class User < ApplicationRecord
    #   cm_admin do
    #     custom_action name: 'submit', verb: 'post', path: ':id/submit' do
    #       def user_submit
    #         Code for action here...
    #       end
    #     end
    #   end
    # end
    def custom_action(name: nil, verb: nil, layout: nil, partial: nil, path: nil, &block)
      @available_actions << CmAdmin::Models::Action.new(name: name, verb: verb, layout: layout, partial: partial, path: path)
      self.class.class_eval(&block)
    end

    def filter(db_column_name, filter_type, options={})
      @filters << CmAdmin::Models::Filter.new(db_column_name: db_column_name, filter_type: filter_type, options: options)
    end
    private

    # Controller defined for each model
    # If model is User, controller will be UsersController
    def define_controller
      klass = Class.new(CmAdmin::ApplicationController) do

        $available_actions.each do |action|
          define_method action.name.to_sym do

            # controller_name & action_name from ActionController
            @model = CmAdmin::Model.find_by(name: controller_name.classify)
            @model.params = params
            @action = CmAdmin::Models::Action.find_by(@model, name: action_name)
            @ar_object = @model.try(action_name, params)
            @ar_object, @associated_model, @associated_ar_object = @model.custom_controller_action(action_name, params.permit!) if !@ar_object.present? && params[:id].present?
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
            respond_to do |format|
              if %w(show index new edit).include?(action_name)
                if request.xhr? && action_name.eql?('index')
                  format.html { render partial: '/cm_admin/main/table' }
                else
                  format.html { render '/cm_admin/main/'+action_name }
                end
              elsif %w(create update destroy).include?(action_name)
                if @ar_object.save
                  format.html { redirect_to  CmAdmin::Engine.mount_path + "/#{@model.name.underscore.pluralize}" }
                else
                  format.html { render '/cm_admin/main/new' }
                end
              elsif action.layout.present?
                if request.xhr? && action.partial.present?
                  format.html { render partial: action.partial }
                else
                  format.html { render action.layout }
                end
              end
            end
          end
        end
      end if $available_actions.present?
      CmAdmin.const_set "#{@name}Controller", klass
    end

    def filter_params(params)
      # OPTIMIZE: Need to check if we can permit the filter_params in a better way
      date_columns = @filters.select{|x| x.filter_type.eql?(:date)}.map(&:db_column_name)
      range_columns = @filters.select{|x| x.filter_type.eql?(:range)}.map(&:db_column_name)
      single_select_columns = @filters.select{|x| x.filter_type.eql?(:single_select)}.map(&:db_column_name)
      multi_select_columns = @filters.select{|x| x.filter_type.eql?(:multi_select)}.map{|x| Hash["#{x.db_column_name}", []]}

      params.require(:filters).permit(:search, date: date_columns, range: range_columns, single_select: single_select_columns, multi_select: multi_select_columns) if params[:filters]
    end
  end
end
