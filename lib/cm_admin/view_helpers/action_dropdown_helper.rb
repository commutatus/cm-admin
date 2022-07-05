module CmAdmin
  module ViewHelpers
    module ActionDropdownHelper
      def available_actions(model_object, action_type)
        case action_type
        when 'custom_action'
          model_object.available_actions.select {
            |act| act if act.route_type.eql?('member') && [:button, :modal].include?(act.display_type)
          }
        else
          model_object.available_actions.select {
            |act| act if act.action_type.eql?(:default) && act.name.eql?(action_type)
          } if has_valid_policy(model_object.name, action_type)
        end
      end
    end
  end
end
