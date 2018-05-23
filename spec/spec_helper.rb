ENV['RACK_ENV'] = 'test'

require 'db_helper'
require 'image_helper'
require 'bundler/setup'
require 'frontend_api'
require 'support/user_mock'
require 'rack/test'
require 'rspec'
require 'json_matchers/rspec'
require 'pry'

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  if config.files_to_run.one?
    config.full_backtrace = true

    config.default_formatter = 'doc'
  end

  config.order = :random

  Kernel.srand(config.seed)

  config.warnings = false

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
    mocks.verify_doubled_constant_names = true
  end

  config.include RSpecMixin

  config.around(:each) do |example|
    DB.transaction(rollback: :always, auto_savepoint: true) { example.run }
  end
end

JsonMatchers.schema_root = 'spec/support/json_schema'

