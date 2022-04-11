require_relative 'constants'
require_relative 'models/action'
require_relative 'models/custom_action'
require_relative 'models/field'
require_relative 'models/form_field'
require_relative 'models/blocks'
require_relative 'models/column'
require_relative 'models/filter'
require_relative 'models/export'
require_relative 'models/cm_show_section'
require_relative 'models/tab'
require_relative 'models/dsl_method'
require_relative 'models/controller_method'
require 'pagy'
require 'axlsx'
require 'cocoon'
require 'pundit'

module CmAdmin
  class Model
    include Pagy::Backend
    include Models::Blocks
    include Models::DslMethod
    include Models::ControllerMethod
    attr_accessor :available_actions, :actions_set, :available_fields, :permitted_fields,
      :current_action, :params, :filters, :available_tabs, :icon_name
    attr_reader :name, :ar_model, :is_visible_on_sidebar

    # Class variable for storing all actions
    # CmAdmin::Model.all_actions
    singleton_class.send(:attr_accessor, :all_actions)

    def initialize(entity, &block)
      @name = entity.name
      @ar_model = entity
      @is_visible_on_sidebar = true
      @icon_name = 'fa fa-th-large'
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
        CmAdmin.config.cm_admin_models.find { |x| x.name == search_hash[:name] }
      end
    end

    def custom_controller_action(action_name, params)
      current_action = CmAdmin::Models::Action.find_by(self, name: action_name.to_s)
      if current_action
        @current_action = current_action
        @ar_object = @ar_model.name.classify.constantize.find(params[:id])
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

    def visible_on_sidebar(visible_option)
      @is_visible_on_sidebar = visible_option
    end

    def set_icon(name)
      @icon_name = name
    end


    private

    # Controller defined for each model
    # If model is User, controller will be UsersController
    def define_controller
      klass = Class.new(CmAdmin::ApplicationController) do
        include Pundit::Authorization
        rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

        $available_actions.each do |action|
          define_method action.name.to_sym do

            # controller_name & action_name from ActionController
            @model = CmAdmin::Model.find_by(name: controller_name.classify)
            @model.params = params
            @action = CmAdmin::Models::Action.find_by(@model, name: action_name)
            @model.current_action = @action
            @ar_object = @model.try(@action.parent || action_name, params)
            @ar_object, @associated_model, @associated_ar_object = @model.custom_controller_action(action_name, params.permit!) if !@ar_object.present? && params[:id].present?
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
            respond_to do |format|
              if %w(show index new edit).include?(action_name)
                if request.xhr? && action_name.eql?('index')
                  format.html { render partial: '/cm_admin/main/table' }
                else
                  format.html { render '/cm_admin/main/'+action_name }
                end
              elsif %w(create update destroy).include?(action_name)
                if @ar_object.save
                  format.html { redirect_to  CmAdmin::Engine.mount_path + "/#{@model.name.underscore.pluralize}", notice: "#{action_name.titleize} #{@ar_object.class.name.downcase} is successful" }
                else
                  format.html { render '/cm_admin/main/new', notice: "#{action_name.titleize} #{@ar_object.class.name.downcase} is unsuccessful" }
                end
              elsif action.action_type == :custom
                if action.child_records
                  format.html { render action.layout }
                elsif action.display_type == :page
                  data = @action.parent == "index" ? @ar_object.data : @ar_object
                  format.html { render action.partial }
                else
                  if @action.code_block.call(@ar_object)
                    redirect_url = @model.current_action.redirection_url || @action.redirection_url || request.referrer || "/cm_admin/#{@model.ar_model.table_name}/#{@ar_object.id}"
                    format.html { redirect_to redirect_url, notice: "#{@action.name.titleize} is successful" }
                  else
                    format.html { redirect_to request.referrer, notice: "#{@action.name.titleize} is unsuccessful" }
                  end
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
        private

        def user_not_authorized
          flash[:alert] = 'You are not authorized to perform this action.'
          redirect_to CmAdmin::Engine.mount_path + '/access-denied'
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
