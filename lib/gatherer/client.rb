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
      if page = page_from(scraper).split?
        parser = Gatherer::CardParser.new(page)
        Card.new_from_parser(parser)
      else
        parsers = Gatherer::SplitCardParser.new(page)

        parsers.map do |parser|
          Card.new_from_parser(parser)
        end
      end
    end

    def expansions(homepage_file = nil, expansion_file = nil)
      expansion_titles(homepage_file).map do |title|
        Gatherer::Expansion.new(
          title: title,
          abbreviation: expansion_abbreviation_for(title, expansion_file)
        )
      end
    end

    def expansion_titles(file = nil)
      file ||= open('http://gatherer.wizards.com')
      doc = Nokogiri::HTML(file)
      expansion_titles = doc.css('select#ctl00_ctl00_MainContent_Content_SearchControls_setAddText')
        .css('option')
        .map {|option| option['value'] }
        .select {|expansion| !expansion.empty?}
    end

    def expansion_abbreviation_for(title, file = nil)
      file ||= open(Scraper.new(expansion: title).url)
      doc = Nokogiri::HTML(file)
      set_images = doc.css('div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ctl00_listRepeater_ctl00_cardSetCurrent img')
      abbreviation = set_images.first['src'].match(/&set=(.[^&]*)/)[1] unless set_images.empty?
    end
  end
end
