require 'open-uri'
require 'nokogiri'
require 'gatherer/card_parser'

module Gatherer
  class Card
    COLOR_SYMBOLS = {
      "Variable Colorless" => "X",
      "White" => "W",
      "Blue" => "U",
      "Black" => "B",
      "Red" => "R",
      "Green" => "G",
      "White or Blue" => "(W/U)",
      "White or Black" => "(W/B)",
      "White or Red" => "(W/R)",
      "White or Green" => "(W/G)",
      "Blue or White" => "(U/W)",
      "Blue or Black" => "(U/B)",
      "Blue or Red" => "(U/R)",
      "Blue or Green" => "(U/G)",
      "Black or White" => "(B/W)",
      "Black or Blue" => "(B/U)",
      "Black or Green" => "(B/G)",
      "Black or Red" => "(B/R)",
      "Red or White" => "(R/W)",
      "Red or Blue" => "(R/U)",
      "Red or Black" => "(R/B)",
      "Red or Green" => "(R/G)",
      "Green or White" => "(G/W)",
      "Green or Blue" => "(G/U)",
      "Green or Black" => "(G/B)",
      "Green or Red" => "(G/R)"
    }

    attr_reader :title,
                :magic_types,
                :mana_cost,
                :converted_mana_cost,
                :subtypes,
                :text,
                :flavor_text,
                :printings,
                :power,
                :toughness,
                :loyalty,
                :illustrator

    def initialize(attributes = {})
      @title = attributes[:title]
      @magic_types = attributes[:magic_types]
      @mana_cost = attributes[:mana_cost]
      @converted_mana_cost = attributes[:converted_mana_cost]
      @subtypes = attributes[:subtypes]
      @text = attributes[:text]
      @flavor_text = attributes[:flavor_text]
      @printings = attributes[:printings]
      @power = attributes[:power]
      @toughness = attributes[:toughness]
      @loyalty = attributes[:loyalty]
      @illustrator = attributes[:illustrator]
    end

    def self.new_from_parser(parser)
      new(
        title: parser.title,
        magic_types: parser.magic_types,
        mana_cost: parser.mana_cost,
        converted_mana_cost: parser.converted_mana_cost,
        subtypes: parser.subtypes,
        text: parser.text,
        flavor_text: parser.flavor_text,
        printings: parser.printings,
        power: parser.power,
        toughness: parser.toughness,
        loyalty: parser.loyalty,
        number: parser.number,
        illustrator: parser.illustrator
      )
    end
  end
end
