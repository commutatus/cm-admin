module CmAdmin
  module ApplicationHelper

    # Allow if policy is not defined.
    def has_valid_policy(model_name, action_name)
      return true unless policy([:cm_admin, model_name.classify.constantize]).methods.include?(:"#{action_name}?")
      policy([:cm_admin, model_name.classify.constantize]).send(:"#{action_name}?")
    end

    def action(action_name)
      case action_name.to_sym
      when :update
        return :edit
      when :create
        return :new
      else
        return action_name.to_sym
      end
    end
  end
end
