require 'cm_admin/version'
require 'cm_admin/engine'
require 'cm_admin/model'
require 'cm_admin/config'

module CmAdmin
  class Error < StandardError; end

  mattr_accessor :layout
  @@included_models ||= []

  def self.setup
    yield self
  end

  def self.config(entity = nil, &block)
    CmAdmin::Config
  end

end
