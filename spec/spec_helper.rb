require "bundler"
Bundler.setup

require "rspec"
require "gatherer"
require "support/matchers"
require "support/fixture"

RSpec.configure do |config|
  config.include Gatherer::Spec::Matchers
end
