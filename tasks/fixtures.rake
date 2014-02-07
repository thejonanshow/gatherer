require 'yaml'
require 'nokogiri'
require 'open-uri'
require './lib/gatherer'

def snake_case(word)
  word.downcase.gsub(/\W/, '_')
end

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

  desc "Generate a card fixture for each multiverse id in index.yml"
  task :cards do
    cards = YAML.load(File.read('spec/fixtures/index.yml'))
    cards.each do |id, name|
      client = Gatherer::Client.new
      scraper = Gatherer::Scraper.new(multiverse_id: id)
      page = client.page_from(scraper).read
      filename = "spec/fixtures/#{snake_case(name)}.html"
      title = page.split("\n").map(&:strip).reject {|w| w.empty?}[4]
      puts "Writing #{filename} with #{title}..."
      File.write(filename, page)
    end
  end
end
