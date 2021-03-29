require 'cm_admin/constants'

module CmAdmin
  class Model
    def initializer(entity, &block)
      @name = entity.name
      @parent_record = entity
      @available_actions ||= []
      yield(&block)
      define_controller
    end

    # Insert into actions according to config block
    def actions(only: [], except: [])
      acts = CmAdmin::DEFAULT_ACTIONS.keys
      acts = acts & only if only.present?
      acts = acts - except if except.present?
      acts.each do |act|
        @available_actions << {action: act, verb: CmAdmin::DEFAULT_ACTIONS[act][:verb])
      end
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
        @available_actions.each do |action|
          define_method action[:action].to_sym do
            model = CmAdmin::Model.find_by(name: controller_name.classify)
            model.send(action_name, params)
          end
        end
      end
      Object.const_set "CmAdmin::#{@name}Controller", klass
    end
  end
end
