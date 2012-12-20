require File.expand_path("../lib/gatherer/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "gatherer"
  s.version     = Gatherer::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jonan Scheffler"]
  s.email       = ["jonanscheffler@gmail.com"]
  s.homepage    = "http://github.com/1337807/gatherer"
  s.summary     = "Gatherer: The Magicking"
  s.description = "Gatherer is a gem to scrape Magic: The Gathering cards."

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "gatherer"
  s.add_dependency "httparty", "~> 0.9.0"
  s.add_dependency "nokogiri", "~> 1.5.5"
  s.files        = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  s.require_path = 'lib'
end
