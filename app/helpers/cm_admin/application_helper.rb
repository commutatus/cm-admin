require "webpacker/helper"

module CmAdmin
  module ApplicationHelper
    include ::Webpacker::Helper

    def current_webpacker_instance
      CmAdmin.webpacker
    end

    # Allow if policy is not defined.
    def has_valid_policy(model_name, action_name)
      return true unless policy([:cm_admin, model_name.classify.constantize]).methods.include?(:"#{action_name}?")
      policy([:cm_admin, model_name.classify.constantize]).send(:"#{action_name}?")
    end
  end
end
