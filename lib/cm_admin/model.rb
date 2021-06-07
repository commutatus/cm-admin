require_relative 'constants'
require_relative 'models/action'
require_relative 'models/field'
require_relative 'models/blocks'
require 'pagy'
module CmAdmin
  class Model
    include Pagy::Backend
    include Models::Blocks
    attr_accessor :available_actions, :actions_set, :available_fields, :permitted_fields, :current_action, :params
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
      puts "Top of the line"
      yield
      # action.instance_eval(&block)
      puts "End of the line"
    end

    def cm_index(&block)
      @current_action = CmAdmin::Models::Action.find_by(self, name: 'index')
      yield
      # action.instance_eval(&block)
    end

    def cm_edit(&block)
      action = CmAdmin::Models::Action.find_by(self, name: 'edit')
      action.instance_eval(&block)
    end

    def show(params)
      @current_action = CmAdmin::Models::Action.find_by(self, name: 'show')
      @ar_object = @ar_model.find(params[:id])
    end

    def index(params)
      @current_action = CmAdmin::Models::Action.find_by(self, name: 'index')
      # Based on the params the filter and pagination object to be set
      @ar_object = filter_by(params)
    end

    def filter_by(params, filter_params={}, sort_params={})
      filtered_result = OpenStruct.new
      sort_column = "users.created_at"
      sort_direction = %w[asc desc].include?(sort_params[:sort_direction]) ? sort_params[:sort_direction] : "asc"
      sort_params = {sort_column: sort_column, sort_direction: sort_direction}
      pagy, records = pagy(self.name.constantize.all)
      filtered_result.data = records
      filtered_result.pagy = pagy
      # filtered_result.facets = paginate(page, raw_data.size)
      # filtered_result.sort = sort_params
      # filtered_result.facets.sort = sort_params
      return filtered_result
    end

    # def paginate(page, total_count)
    #   page = page.presence || 1
    #   per_page = 30
    #   facets = OpenStruct.new # initializing OpenStruct instance
    #   facets.total_count = total_count
    #   facets.filtered_count = total_count
    #   facets.total_pages = (total_count/per_page.to_f).ceil
    #   facets.current_page = page.to_i
    #   # Previous Page
    #   if facets.current_page - 1 == 0
    #     facets.previous_page = false
    #   else
    #     facets.previous_page = true
    #   end
    #   # Next Page
    #   if facets.current_page + 1 > facets.total_pages
    #     facets.next_page = false
    #   else
    #     facets.next_page = true
    #   end
    #   return facets
    # end
    def new(params)
      @ar_object = @ar_model.new
    end

    def edit(params)
      @ar_object = @ar_model.find(params[:id])
    end

    def update(params)
      @ar_object = @ar_model.find(params[:id])
      @ar_object.update(resource_params(params))
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

    def column(field_name)
      puts "For printing field #{field_name}"
      @available_fields[:index] << field_name unless @available_fields[:index].include?(field_name)
    end

    def all_db_columns(options={})
      field_names = self.instance_variable_get(:@ar_model)&.columns&.map{|x| x.name.to_sym}
      if options.include?(:exclude) && field_names
        excluded_fields = (Array.new << options[:exclude]).flatten.map(&:to_sym)
        field_names -= excluded_fields
      end
      current_action_name = @current_action.name.to_sym
      @available_fields[current_action_name] |= field_names if field_names
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
                format.html { render '/cm_admin/main/'+action_name }
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
  end
end
