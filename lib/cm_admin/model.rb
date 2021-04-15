require_relative 'constants'
require_relative 'models/action'
require_relative 'models/blocks'

module CmAdmin
  class Model
    include Models::Blocks
    attr_accessor :available_actions, :actions_set
    attr_reader :name, :ar_model

    # Class variable for storing all actions
    # CmAdmin::Model.all_actions
    singleton_class.send(:attr_accessor, :all_actions)

    def initialize(entity, &block)
      @name = entity.name
      @ar_model = entity
      @available_actions ||= []
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
        @available_actions << CmAdmin::Models::Action.new(name: act.to_s, verb: CmAdmin::DEFAULT_ACTIONS[act][:verb])
      end
      @actions_set = true
    end

    def cm_show
      puts "Top of the line"
      yield
      puts "End of the line"
    end

    def cm_index(&block)
      action = CmAdmin::Models::Action.find_by(self, name: 'index')
      action.instance_eval(&block)
    end

    def show(params)
      puts "Params is #{params}"
    end

    def index(params)
      puts "Index page"
    end

    def field(field_name)
      puts "For printing field #{field_name}"
    end

    def self.find_by(search_hash)
      CmAdmin.cm_admin_models.find { |x| x.name == search_hash[:name] }
    end

    # Custom actions
    # eg
    # class User < ApplicationRecord
    #   cm_admin do
    #     custom_action name: 'submit', verb: 'post' do
    #       def user_submit
    #         Code for action here...
    #       end
    #     end
    #   end
    # end
    def custom_action(name: nil, verb: nil, layout: nil, partial: nil, &block)
      @available_actions << CmAdmin::Models::Action.new(name: name, verb: verb, layout: layout, partial: partial)
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
            @model.send(action_name, params)
            # respond_to do |format|
            #   if %w(show index create new edit destroy update).include?(action_name)
            #     if action.partial.present?
            #       render partial: action.partial
            #     else
                  render 'layouts/index', layout: false
            #     end
            #   elsif action.layout.present?
            #     if action.partial.present?
            #       render partial: action.partial, layout: action.layout
            #     else
            #       render layout: action.layout
            #     end
            #   end
            # end
          end
        end
      end if $available_actions.present?
      CmAdmin.const_set "#{@name}Controller", klass
    end
  end
end
