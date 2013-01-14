require 'nokogiri'
require 'open-uri'
require './lib/gatherer'

namespace :fixtures do
  desc "Generate the expansions yaml fixture using the homepage html fixture"
  task :expansions do
    expansions_file = 'spec/fixtures/expansions.yml'

    expansions = Gatherer::Client.new.expansions

    File.write(expansions_file, YAML::dump(expansions))
    expansions.each {|exp| puts exp.title}
    puts "==="
    puts "Created #{expansions_file} with #{expansions.length} expansions."
    puts "==="
  end
end
