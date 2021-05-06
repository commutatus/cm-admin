module CmAdmin
  class ApplicationController < ::ActionController::Base
    include Pagy::Backend
    layout 'cm_admin'
    helper CmAdmin::ViewHelpers
    before_action :set_pagination

    def set_pagination
       @pagy, @records = pagy(User.all)
    end
  end
end
