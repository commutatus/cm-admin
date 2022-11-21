ENV['RAILS_ENV'] = 'test'

CI_ORM = (ENV['CI_ORM'] || :active_record).to_sym

require File.expand_path('../dummy/config/environment', __FILE__)

require "bundler/setup"
# require "cm_admin"
require_relative "orm/#{CI_ORM}"
require 'rspec/rails'
require 'capybara/rails'

Dir[File.expand_path('../support/**/*.rb', __FILE__), 
    File.expand_path('../shared_examples/**/*.rb', __FILE__)].each { |f| require f }


RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.include CmAdmin::Engine.routes.url_helpers
  config.include Capybara::DSL, type: :request
end
