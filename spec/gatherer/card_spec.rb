require "spec_helper"

describe Gatherer::Card do
  it "can be created with a title" do
    card = Gatherer::Card.new(title: "Endbringer")
    card.title.should == "Endbringer"
  end

  it "can be created with types" do
    card = Gatherer::Card.new(types: ["Artifact Creature"])
    card.types.should == ["Artifact Creature"]
  end

  it "can be created with a mana_cost" do
    card = Gatherer::Card.new(mana_cost: "BBB")
    card.mana_cost.should == "BBB"
  end

  it "can be created with a converted_mana_cost" do
    card = Gatherer::Card.new(converted_mana_cost: 3)
    card.converted_mana_cost.should == 3
  end

  it "can be created with subtypes" do
    card = Gatherer::Card.new(subtypes: ["Immortal"])
    card.subtypes.should == ["Immortal"]
  end

  it "can be created with text" do
    card = Gatherer::Card.new(text: "Indestructible\nSacrifice Endbringer: Destroy all permanents. Activate this ability only if your life total is 1.")
    card.text.should == "Indestructible\nSacrifice Endbringer: Destroy all permanents. Activate this ability only if your life total is 1."
  end

  it "can be created with a flavor_text" do
    card = Gatherer::Card.new(flavor_text: "Bring it.")
    card.flavor_text.should == "Bring it."
  end

  it "can be created with a printings" do
    expansion = Gatherer::Expansion.new(title: "Magic 2014")
    printing = Gatherer::Printing.new(expansion: expansion, rarity: "Mythic Rare", number: 7)
    card = Gatherer::Card.new(printings: [printing])
    card.printings.should == [printing]
  end

  it "can be created with a power" do
    card = Gatherer::Card.new(power: "5")
    card.power.should == "5"
  end

  it "can be created with a toughness" do
    card = Gatherer::Card.new(toughness: "5")
    card.toughness.should == "5"
  end

  it "can be created with loyalty" do
    card = Gatherer::Card.new(loyalty: 5)
    card.loyalty.should == 5
  end

  it "can be created with a illustrator" do
    card = Gatherer::Card.new(illustrator: "rk post")
    card.illustrator.should == "rk post"
  end

  it "can be created from a parser" do
    parser = Gatherer::CardParser.new(Fixture.html 'magical_hack')
    card = Gatherer::Card.new_from_parser(parser)
    card.title.should == "Magical Hack"
  end

  context ".new_from_parser" do
    it "collects all of the attributes from the parser" do
      parser = Gatherer::CardParser.new(Fixture.html 'magical_hack')

      Gatherer::Card.new.instance_variables.each do |instance_variable|
        parser.should_receive(instance_variable[1..-1])
      end

      card = Gatherer::Card.new_from_parser(parser)
    end
  end
end
