RSpec::Expectations.configuration.warn_about_potential_false_positives = false

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.fail_fast = false
  # TODO maybe add `config.render_views = true`.

  config.before :suite do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
  end

  config.before :all do
    DeferredGarbageCollection.start
  end

  config.after :all do
    DeferredGarbageCollection.reconsider
  end

  config.before :each do
    DatabaseCleaner.start
  end

  config.after :each do
    DatabaseCleaner.clean
  end

  config.around :each, feed: true do |example|
    Feed.enabled = true
    example.run
    Feed.enabled = false
  end

  config.infer_spec_type_from_file_location!
  config.include Devise::TestHelpers, type: :controller

  # To avoid typing `FactoryBot.create` all the time (use `create`).
  config.include FactoryBot::Syntax::Methods
end
