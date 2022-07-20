module CmAdmin
  module ViewHelpers
    module ActionDropdownHelper
      def available_actions(cm_model, action_type)
        if action_type.eql?('custom_actions')
          cm_model.available_actions.select {
            |act| act if act.route_type.eql?('member') &&
                         [:button, :modal].include?(act.display_type) &&
                         act.name.present? &&
                         has_valid_policy(cm_model.name, act.name)
          }
        else
          cm_model.available_actions.select {
            |act| act if act.action_type.eql?(:default) &&
                         act.name.eql?(action_type)
          } if has_valid_policy(cm_model.name, action_type)
        end
      end
    end
  end
end
