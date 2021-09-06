require "webpacker/helper"

module CmAdmin
  module ApplicationHelper
    include ::Webpacker::Helper

    def current_webpacker_instance
      CmAdmin.webpacker
    end
  end
end
