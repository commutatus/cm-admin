require 'slim'
require 'cm_admin/version'
require 'cm_admin/engine'
require 'cm_admin/model'
require 'cm_admin/view_helpers'

module CmAdmin
  class ExportsController < ApplicationController

    def export
      file_path = CmAdmin::Models::Export.generate_excel(params[:class_name], params[:columns])
      send_file file_path, :disposition => 'attachment'
    end

    def ajax_download
      file = File.open(params[:file_path], "rb")
      contents = file.read
      file.close
      send_data(contents, :filename => params[:file_path].split('/').last)
      File.delete(params[:file_path]) if File.exist?(params[:file_path])
    end

  end
end
