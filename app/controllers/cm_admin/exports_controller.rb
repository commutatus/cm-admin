require 'slim'
require 'cm_admin/version'
require 'cm_admin/engine'
require 'cm_admin/model'
require 'cm_admin/view_helpers'

module CmAdmin
  class ExportsController < ApplicationController
    skip_before_action :verify_authenticity_token

    def export
      file_path = CmAdmin::Models::Export.generate_excel(params[:class_name], params, helpers)
      send_file file_path, disposition: 'attachment'
    end

  end
end
