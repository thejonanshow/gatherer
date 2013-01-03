module Gatherer
  class Printing
    attr_reader :expansion, :rarity

    def initialize(attributes)
      @expansion = attributes[:expansion]
      @rarity = attributes[:rarity]
    end
  end
end
