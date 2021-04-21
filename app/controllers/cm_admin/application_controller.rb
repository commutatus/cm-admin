module CmAdmin
  class ApplicationController < ::ActionController::Base
    layout 'cm_admin'
    helper CmAdmin::ViewHelpers
  end
end
