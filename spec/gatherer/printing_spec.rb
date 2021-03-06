require 'spec_helper'

describe Gatherer::Printing do
  let(:expansion) {
    Gatherer::Expansion.new(title: "Magic 2014", abbreviation: "M14")
  }
  let(:printing) {
    Gatherer::Printing.new(
      expansion: expansion,
      rarity: "Rare",
      number: 7)
  }

  it "can be created with an expansion, a rarity and a number" do
    printing.expansion.should be expansion
    printing.rarity.should == "Rare"
    printing.number.should == 7
  end

  context "#to_hash" do
    it "returns a hash of printing attributes" do
      printing.to_hash.should == {
        expansion: {title: expansion.title, abbreviation: expansion.abbreviation},
        rarity: printing.rarity,
        number: printing.number
      }
    end
  end
end
