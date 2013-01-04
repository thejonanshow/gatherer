require 'open-uri'
require 'gatherer/scraper'
require 'gatherer/card_parser'

module Gatherer
  class Client
    def fetch_by_multiverse_id(id)
      card_from(scraper(id))
    end

    def scraper(id)
      Gatherer::Scraper.new(multiverse_id: id)
    end

    def page_from(scraper)
      open(scraper.url)
    end

    def card_from(scraper)
      parser = Gatherer::CardParser.new(page_from(scraper))
      Card.new_from_parser(parser)
    end
  end
end
