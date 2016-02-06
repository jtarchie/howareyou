ENV['RAILS_ENV'] ||= 'test'
require 'rails/all'
require 'rspec/rails'

ENV['TWILIO_ACCOUNT_SID'] ||= 'fake_token'
ENV['TWILIO_AUTH_TOKEN']  ||= 'fake_token'
ENV['DATABASE_URL'] = 'sqlite3::memory:'
ENV['SECRET_KEY_BASE'] = 'none'

require_relative '../app'
load "#{Rails.root}/db/schema.rb"

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
