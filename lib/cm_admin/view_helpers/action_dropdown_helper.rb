module CmAdmin
  module ViewHelpers
    module ActionDropdownHelper
      def available_actions(model_object, action_type)
        case action_type
        when 'custom_actions'
          model_object.available_actions.select {
            |act| act if act.route_type.eql?('member') &&
                         [:button, :modal].include?(act.display_type) &&
                         act.name.present? &&
                         has_valid_policy(model_object.name, act.name)
          }
        when 'custom_actions_modals'
          model_object.available_actions.select {
            |act| act if act.route_type.eql?('member') &&
                         act.display_type.eql?(:modal) &&
                         act.name.present? &&
                         has_valid_policy(model_object.name, act.name)
          }
        else
          model_object.available_actions.select {
            |act| act if act.action_type.eql?(:default) &&
                         act.name.eql?(action_type)
          } if has_valid_policy(model_object.name, action_type)
        end
      end
    end
  end
end
