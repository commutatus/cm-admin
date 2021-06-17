require_relative 'constants'
require_relative 'models/action'
require_relative 'models/field'
require_relative 'models/form_field'
require_relative 'models/blocks'
require_relative 'models/column'
require_relative 'models/filter'
require_relative 'models/export'
require 'pagy'
require 'axlsx'


module CmAdmin
  class Model
    include Pagy::Backend
    include Models::Blocks
    attr_accessor :available_actions, :actions_set, :available_fields, :permitted_fields, :current_action, :params, :filters
    attr_reader :name, :ar_model

    # Class variable for storing all actions
    # CmAdmin::Model.all_actions
    singleton_class.send(:attr_accessor, :all_actions)

    def initialize(entity, &block)
      @name = entity.name
      @ar_model = entity
      @available_actions ||= []
      @current_action = nil
      @available_fields ||= {index: [], show: [], edit: [], new: []}
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

    def cm_show(&block)
      @current_action = CmAdmin::Models::Action.find_by(self, name: 'show')
      yield
    end

    def cm_edit(&block)
      @current_action = CmAdmin::Models::Action.find_by(self, name: 'edit')
      yield
    end

    def cm_new(&block)
      @current_action = CmAdmin::Models::Action.find_by(self, name: 'new')
      yield
    end

    def cm_index(&block)
      @current_action = CmAdmin::Models::Action.find_by(self, name: 'index')
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
      @ar_object = filter_by(params, filter_params=filter_params(params))
    end

    def filter_by(params, filter_params={}, sort_params={})
      filtered_result = OpenStruct.new
      sort_column = "users.created_at"
      sort_direction = %w[asc desc].include?(sort_params[:sort_direction]) ? sort_params[:sort_direction] : "asc"
      sort_params = {sort_column: sort_column, sort_direction: sort_direction}
      final_data = filtered_data(filter_params)
      pagy, records = pagy(final_data)
      filtered_result.data = records
      filtered_result.pagy = pagy
      # filtered_result.facets = paginate(page, raw_data.size)
      # filtered_result.sort = sort_params
      # filtered_result.facets.sort = sort_params
      return filtered_result
    end

    def filtered_data(filter_params)
      records = self.name.constantize.where(nil)
      if filter_params
        filter_params.each do |scope, scope_value|
          records = self.send("cm_#{scope}", scope_value, records)
        end
      end
      records
    end

    def cm_search(scope_value, records)
      return nil if scope_value.blank?
      table_name = records.table_name

      @filters.select{|x| x if x.filter_type.eql?(:search)}.each do |filter|
        terms = scope_value.downcase.split(/\s+/)
        terms = terms.map { |e|
          (e.gsub('*', '%').prepend('%') + '%').gsub(/%+/, '%')
        }
        sql = ""
        filter.db_column_name.each.with_index do |column, i|
          sql.concat("#{table_name}.#{column} ILIKE ?")
          sql.concat(' OR ') unless filter.db_column_name.size.eql?(i+1)
        end

        records = records.where(
          terms.map { |term|
            sql
          }.join(' AND '),
          *terms.map { |e| [e] * filter.db_column_name.size }.flatten
        )
      end
      records
    end

    def new(params)
      @ar_object = @ar_model.new
    end

    def edit(params)
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

    def resource_params(params)
      permittable_fields = @permitted_fields || @ar_model.columns.map(&:name).reject { |i| CmAdmin::REJECTABLE_FIELDS.include?(i) }.map(&:to_sym)
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

    def field(field_name, options={})
      puts "For printing field #{field_name}"
      @available_fields[:show] << CmAdmin::Models::Field.new(field_name, options)
    end

    def form_field(field_name, options={})
      @available_fields[@current_action.name.to_sym] << CmAdmin::Models::FormField.new(field_name, options)
    end

    def column(field_name, options={})
      unless @available_fields[:index].map{|x| x.db_column_name.to_sym}.include?(field_name)
        puts "For printing column #{field_name}"
        @available_fields[:index] << CmAdmin::Models::Column.new(field_name, options)
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

    def self.find_by(search_hash)
      CmAdmin.cm_admin_models.find { |x| x.name == search_hash[:name] }
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
            @ar_object = @model.send(action_name, params)
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
                if action.partial.present?
                  render partial: action.partial, layout: action.layout
                else
                  render layout: action.layout
                end
              end
            end
          end
        end
      end if $available_actions.present?
      CmAdmin.const_set "#{@name}Controller", klass
    end

    def filter_params(params)
      params.require(:filters).permit(:search) if params[:filters]
    end
  end
end
