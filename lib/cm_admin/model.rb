require 'cm_admin/constants'

module CmAdmin
  class Model
    attr_accessor :available_actions, :actions_set
    attr_reader :name, :parent_record

    def initialize(entity, &block)
      @name = entity.name
      @parent_record = entity
      @available_actions ||= []
      instance_eval(&block) if block_given?
      actions unless @actions_set
      $available_actions = @available_actions
      define_controller
    end

    # Insert into actions according to config block
    def actions(only: [], except: [])
      acts = CmAdmin::DEFAULT_ACTIONS.keys
      acts = acts & (Array.new << only).flatten if only.present?
      acts = acts - (Array.new << except).flatten if except.present?
      acts.each do |act|
        @available_actions << {action: act, verb: CmAdmin::DEFAULT_ACTIONS[act][:verb]}
      end
      @actions_set = true
    end

    def cm_show
      puts "Top of the line"
      yield
      puts "End of the line"
    end

    def show(params)
      puts "Params is #{params}"


    end

    def field(field_name)
      puts "For printing field #{field_name}"
    end

    def self.find_by(search_hash)
      CmAdmin.cm_admin_models.select{|x| x.name == search_hash[:name]}.first
    end

    # Custom actions
    # eg
    # class User < ApplicationRecord
    #   cm_admin do
    #     custom_action 'submit', 'post' do
    #       def user_submit
    #         Code for action here...
    #       end
    #     end
    #   end
    # end
    def custom_action(name, verb, &block)
      @available_actions << {action: name, verb: verb}
      self.class.class_eval(&block)
    end

    private

    # Controller defined for each model
    # If model is User, controller will be UsersController
    def define_controller
      klass = Class.new(CmAdmin::ApplicationController) do

        $available_actions.each do |action|
          define_method action[:action].to_sym do
            model = CmAdmin::Model.find_by(name: controller_name.classify)
            model.send(action_name, params)
            respond_to do |format|
              format.html {render partial: '/cm_admin/main/'+action_name}
            end
          end
        end
      end if $available_actions.present?
      CmAdmin.const_set "#{@name}Controller", klass
    end
  end
end
