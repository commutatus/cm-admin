require 'slim'
require 'cm_admin/version'
require 'cm_admin/engine'
require 'cm_admin/model'
require 'cm_admin/view_helpers'

module CmAdmin
  class ExportsController < ApplicationController

    def export
      respond_to do |format|
        format.xlsx {response.headers['Content-Disposition'] = "attachment; filename='users.xlsx'"}
      end
    end
  end
end
