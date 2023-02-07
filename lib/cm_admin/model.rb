require_relative 'constants'
require_relative 'models/action'
require_relative 'models/importer'
require_relative 'models/custom_action'
require_relative 'models/field'
require_relative 'models/form_field'
require_relative 'models/blocks'
require_relative 'models/column'
require_relative 'models/filter'
require_relative 'models/export'
require_relative 'models/cm_section'
require_relative 'models/tab'
require_relative 'models/dsl_method'
require 'pagy'
require 'axlsx'
require 'cocoon'
require 'pundit'
require 'local_time'
require 'csv_importer'

module CmAdmin
  class Model
    include Pagy::Backend
    include Models::Blocks
    include Models::DslMethod
    attr_accessor :available_actions, :actions_set, :available_fields, :additional_permitted_fields,
      :current_action, :params, :filters, :available_tabs, :icon_name
    attr_reader :name, :ar_model, :is_visible_on_sidebar, :importer

    def initialize(entity, &block)
      @name = entity.name
      @ar_model = entity
      @is_visible_on_sidebar = true
      @icon_name = 'fa fa-th-large'
      @available_actions ||= []
      @additional_permitted_fields ||= []
      @current_action = nil
      @available_tabs ||= []
      @available_fields ||= {index: [], show: [], edit: {fields: []}, new: {fields: []}}
      @params = nil
      @filters ||= []
      instance_eval(&block) if block_given?
      actions unless @actions_set
      $available_actions = @available_actions.dup
      define_controller
    end

    class << self

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

    def importable(class_name:, importer_type:)
      @importer = CmAdmin::Models::Importer.new(class_name, importer_type)
    end

    def visible_on_sidebar(visible_option)
      @is_visible_on_sidebar = visible_option
    end

    def set_icon(name)
      @icon_name = name
    end

    def permit_additional_fields(fields=[])
      @additional_permitted_fields = fields
    end

    # Shared between export controller and resource controller
    def filter_params(params)
      # OPTIMIZE: Need to check if we can permit the filter_params in a better way
      date_columns = self.filters.select{|x| x.filter_type.eql?(:date)}.map(&:db_column_name)
      range_columns = self.filters.select{|x| x.filter_type.eql?(:range)}.map(&:db_column_name)
      single_select_columns = self.filters.select{|x| x.filter_type.eql?(:single_select)}.map(&:db_column_name)
      multi_select_columns = self.filters.select{|x| x.filter_type.eql?(:multi_select)}.map{|x| Hash["#{x.db_column_name}", []]}

      params.require(:filters).permit(:search, date: date_columns, range: range_columns, single_select: single_select_columns, multi_select: multi_select_columns) if params[:filters]
    end

    private

    # Controller defined for each model
    # If model is User, controller will be UsersController
    def define_controller
      klass = Class.new(CmAdmin::ResourceController) do
        include Pundit::Authorization
        rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

        $available_actions.each do |action|
          define_method action.name.to_sym do

            # controller_name & action_name from ActionController
            @model = CmAdmin::Model.find_by(name: controller_name.classify)
            @model.params = params
            @action = CmAdmin::Models::Action.find_by(@model, name: action_name)
            @model.current_action = @action
            send(@action.controller_action_name, params)
            # @ar_object = @model.try(@action.parent || action_name, params)
          end
        end

        def pundit_user
          Current.user
        end
        private

        def user_not_authorized
          flash[:alert] = 'You are not authorized to perform this action.'
          redirect_to CmAdmin::Engine.mount_path + '/access-denied'
        end
      end if $available_actions.present?
      CmAdmin.const_set "#{@name}Controller", klass
    end

    
  end
end
