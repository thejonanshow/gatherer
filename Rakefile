require "bundler"
Bundler.setup

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

gemspec = eval(File.read("gatherer.gemspec"))

task :build => "#{gemspec.full_name}.gem"

file "#{gemspec.full_name}.gem" => gemspec.files + ["gatherer.gemspec"] do
  system "gem build gatherer.gemspec"
  system "gem install gatherer-#{gatherer::VERSION}.gem"
end

Dir.glob('tasks/*.rake').each { |r| import r }
