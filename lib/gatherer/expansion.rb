module Gatherer
  class Expansion
    attr_reader :title, :abbreviation

    def initialize(attributes)
      @title = attributes[:title]
      @abbreviation = attributes[:abbreviation]
    end

    def to_hash
      {
        title: @title,
        abbreviation: @abbreviation
      }
    end
  end
end
