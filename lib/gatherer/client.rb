require 'open-uri'
require 'gatherer/scraper'
require 'gatherer/card_parser'

module Gatherer
  class Client
    def fetch_by_multiverse_id(id)
      card_from(multiverse_scraper(id))
    end

    def multiverse_scraper(id)
      Gatherer::Scraper.new(multiverse_id: id)
    end

    def page_from(scraper)
      open(scraper.url)
    end

    def card_from(scraper)
      parser = Gatherer::CardParser.new(page_from(scraper))
      Card.new_from_parser(parser)
    end

    def expansions(file = nil)
      file ||= open('http://gatherer.wizards.com')
      doc = Nokogiri::HTML(file)
      expansions = doc.css('select#ctl00_ctl00_MainContent_Content_SearchControls_setAddText')
        .css('option')
        .map {|option| option['value'] }
        .select {|expansion| !expansion.empty?}
    end
  end
end
