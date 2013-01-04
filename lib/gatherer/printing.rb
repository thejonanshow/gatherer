module Gatherer
  class Printing
    attr_reader :expansion, :rarity, :number

    def initialize(attributes)
      @expansion = attributes[:expansion]
      @rarity = attributes[:rarity]
      @number = attributes[:number]
    end

    def to_hash
      {
        expansion: @expansion.to_hash,
        rarity: @rarity,
        number: @number
      }
    end
  end
end
