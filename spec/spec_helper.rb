require 'simplecov'
require 'coveralls'
Coveralls.wear_merged!('rails')
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start 'rails' do
   use_merging true
   SimpleCov.merge_timeout 3600
   SimpleCov.command_name 'rspec'
   coverage_dir 'coverage'
end
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
ActiveRecord::Migration.maintain_test_schema!
require 'rubygems'
require 'database_cleaner'
require 'paperclip/matchers'
require 'fakeweb'
FakeWeb.allow_net_connect = %r[^https?://coveralls.io]
ActiveRecord::Migration.maintain_test_schema! if defined?(ActiveRecord::Migration)
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
# require 'rspec/autorun'
# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
RSpec.configure do |config|
  config.mock_with :rspec
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = false
  config.alias_example_to :expect_it
  config.example_status_persistence_file_path = "examples.txt"

  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
  config.include FactoryGirl::Syntax::Methods
  config.include Paperclip::Shoulda::Matchers
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.include Devise::TestHelpers, :type => :controller
  config.extend ControllerMacros, :type => :controller
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end
  config.before(:each, type: :feature) do
    DatabaseCleaner.strategy = [:truncation, pre_count: true]
  end
  config.before(:each, truncate: true) do
    DatabaseCleaner.strategy = [:truncation, pre_count: true]
  end
  config.before(:each) do
    DatabaseCleaner.start
    FakeWeb.clean_registry
  end
  config.after(:each) do
    DatabaseCleaner.clean
  end
  def (ActionDispatch::Integration::Session).fixture_path
    RSpec.configuration.fixture_path
  end
end

OmniAuth.config.test_mode = true
