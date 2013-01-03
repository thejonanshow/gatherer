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

    attr_reader :title, :types

    def initialize(attributes = {})
      @title = attributes[:title]
      @types = attributes[:types]
    end
  end
end
