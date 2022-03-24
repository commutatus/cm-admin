module CmAdmin
  class ApplicationController < ::ActionController::Base
    include Pundit::Authorization
    # before_action :check_cm_admin
    layout 'cm_admin'
    helper CmAdmin::ViewHelpers


    def check_cm_admin
      redirect_to CmAdmin::Engine.mount_path + '/access-denied' unless defined?(::Current) && ::Current.cm_admin_user
    end

  end
end
