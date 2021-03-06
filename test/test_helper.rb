ENV["RACK_ENV"] ||= "test"
require 'simplecov'
SimpleCov.start
require 'bundler'
Bundler.require

require File.expand_path("../../config/environment", __FILE__)
require 'minitest/autorun'
require 'capybara'
require 'database_cleaner'
# require 'simplecov'

Capybara.app = TrafficSpy::Server

DatabaseCleaner.strategy = :truncation, {except: %w[public.schema_migrations]}

class MiniTest::Test
  def app
    TrafficSpy::Server
  end

  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end
end

class ControllerTest < Minitest::Test
  include Rack::Test::Methods
end

class FeatureTest < Minitest::Test
  include Capybara::DSL
  include Rack::Test::Methods
end
