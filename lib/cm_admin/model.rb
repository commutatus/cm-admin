require_relative 'constants'
require_relative 'models/action'
require_relative 'models/blocks'

module CmAdmin
  class Model
    include Models::Blocks
    attr_accessor :available_actions, :actions_set, :available_fields, :permitted_fields, :export_enabled
    attr_reader :name, :ar_model

    # Class variable for storing all actions
    # CmAdmin::Model.all_actions
    singleton_class.send(:attr_accessor, :all_actions)

    def initialize(entity, &block)
      @name = entity.name
      @ar_model = entity
      @available_actions ||= []
      @available_fields ||= {index: [], show: [], edit: [], export: []}
      @export_enabled = false
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
      acts = CmAdmin::DEFAULT_ACTIONS.except(:export).keys
      acts = acts & (Array.new << only).flatten if only.present?
      acts = acts - (Array.new << except).flatten if except.present?
      acts << :export if @export_enabled
      acts.each do |act|
        action_defaults = CmAdmin::DEFAULT_ACTIONS[act]
        @available_actions << CmAdmin::Models::Action.new(name: act.to_s, verb: action_defaults[:verb], path: action_defaults[:path])
      end
      @actions_set = true
    end

    def cm_show(&block)
      puts "Top of the line"
      # action = CmAdmin::Models::Action.find_by(self, name: 'index')
      yield
      # action.instance_eval(&block)
      puts "End of the line"
    end

    def cm_index(&block)
      yield
      # action = CmAdmin::Models::Action.find_by(self, name: 'index')
      # action.instance_eval(&block)
    end

    def cm_edit(&block)
      action = CmAdmin::Models::Action.find_by(self, name: 'edit')
      action.instance_eval(&block)
    end

    def cm_export
      @export_enabled = true
    end

    def show(params)
      @ar_object = @ar_model.find(1)
    end

    def index(params)
      # Based on the params the filter and pagination object to be set
      @ar_object = @ar_model.all
    end

    def edit(params)
      @ar_object = @ar_model.find(params[:id])
    end

    def update(params)
      @ar_object = @ar_model.find(params[:id])
      @ar_object.update(resource_params(params))
    end

    # Column validation can be added here
    # Currently its done in the job
    def export(params)
      CmAdmin::ExportJob.perform_later(self, params)
    end

    def resource_params(params)
      permittable_fields = @permitted_fields || @ar_model.columns.map(&:name).reject { |i| CmAdmin::REJECTABLE_FIELDS.include?(i) }.map(&:to_sym)
      params.require(self.name.underscore.to_sym).permit(*permittable_fields)
    end

    # Generalize and move to action
    # All 3 are having same function. Combine to one method and move to action.
    # The instance eval from edit should give an idea.
    def field(field_name)
      puts "For printing field #{field_name}"
      @available_fields[:show] << field_name
    end

    def column(field_name)
      puts "For printing field #{field_name}"
      @available_fields[:index] << field_name
    end

    # Example
    # belongs_to :user
    # cm_admin do
    #   cm_export do
    #     attrib :title
    #     attrib :created_at, name: 'Creation time'
    #     attrib :creator, methods: [:user, :name]
    #   end
    # end
    def attrib(field_name, options = {})
      @available_fields[:export] << {field_name: field_name}.merge(options)
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
            @action = CmAdmin::Models::Action.find_by(@model, name: action_name)
            @ar_object = @model.send(action_name, params)
            redirect_to "/admin/#{@model.name.underscore.pluralize}/index" if %w(create update destroy export).include?(action_name)
            # respond_to do |format|
              if %w(show index new edit).include?(action_name)
                if action.partial.present?
                  render partial: action.partial
                else
                  render "layouts/#{action_name}", layout: false
                # format.html { render '/cm_admin/main/'+action_name }
                end
              elsif action.layout.present?
                if action.partial.present?
                  render partial: action.partial, layout: action.layout
                else
                  render layout: action.layout
                end
              end
            # end
          end
        end
      end if $available_actions.present?
      CmAdmin.const_set "#{@name}Controller", klass
    end
  end
end
