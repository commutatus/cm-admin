require "cm_admin/version"
require "cm_admin/engine"

module CmAdmin
  class Error < StandardError; end

  mattr_accessor :layout
  @@layout = 'admin'

  def self.setup
    yield self
  end
end
