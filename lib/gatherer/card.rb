require 'nokogiri'
require 'gatherer/card_parser'

module Gatherer
  class Card
    include Gatherer::CardParser
    attr_reader :title

    def initialize(attributes = {})
      @title = attributes[:title]
    end
  end
end
