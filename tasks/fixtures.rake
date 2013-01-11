require 'nokogiri'
require 'open-uri'

namespace :fixtures do
  desc "Generate the expansions yaml fixture using the homepage html fixture"
  task :expansions do
    expansions_file = 'spec/fixtures/expansions.yml'

    begin
      file = open('http://gatherer.wizards.com')
    rescue StandardError => e
      puts "Open URI returned an error opening http://gatherer.wizards.com"
      puts e.inspect
      puts "Falling back to spec/fixtures/homepage.html"
      file = File.read('spec/fixtures/homepage.html')
    end

    doc = Nokogiri::HTML(file)
    expansions = doc.css('select#ctl00_ctl00_MainContent_Content_SearchControls_setAddText')
    .css('option')
    .map {|option| option['value'] }
    .select {|expansion| !expansion.empty?}
    File.write(expansions_file, YAML::dump(expansions))
    expansions.each {|exp| puts exp}
    puts "==="
    puts "Created #{expansions_file} with #{expansions.length} expansions."
    puts "==="
  end
end
