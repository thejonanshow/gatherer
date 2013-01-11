require 'spec_helper'
require 'gatherer/card_parser'

describe Gatherer::CardParser do
  it "should raise a card not found error unless given html with a card" do
    expect { Gatherer::CardParser.new("<div></div>") }.to raise_error Gatherer::CardNotFound
  end

  context "given html" do
    let(:parser) { Gatherer::CardParser.new(Fixture.html 'magical_hack') }

    it "correctly determines the title" do
      parser.title.should == "Magical Hack"
    end

    it "correctly determines the types" do
      parser.types.should == ['Instant']
    end

    it "correctly determines the mana cost" do
      parser.mana_cost.should == "U"
    end

    it "correctly determines the converted mana cost" do
      parser.converted_mana_cost.should == 1
    end

    it "correctly determines the subtypes" do
      parser.subtypes.should == []
    end

    it "correctly determines the text" do
      parser.text.should == "Change the text of target spell or permanent by replacing all instances of one basic land type with another. (For example, you may change \"swampwalk\" to \"plainswalk.\" This effect lasts indefinitely.)"
    end

    it "correctly determines the flavor text" do
      parser.flavor_text.should == ""
    end

    it "correctly determines the printings" do
      titles = parser.printings.map { |printing| printing.expansion.title }

      titles.should == ["Limited Edition Alpha", "Limited Edition Beta", "Unlimited Edition", "Revised Edition", "Fourth Edition", "Fifth Edition"]
      parser.printings.map(&:rarity).uniq.should == ["Rare"]
    end

    context "current printings" do
      let(:parser) { Gatherer::CardParser.new(Fixture.html 'nicol_bolas_planeswalker') }

      it "correctly assigns the current printing" do
        parser.current_printing.expansion.title.should == "Magic 2013"
      end

      it "correctly assigns the card number to the current printing" do
        parser.current_printing.number.should == 199
      end

      it "does not assign the card number to other printings" do
        parser.printings.map(&:number).should == [199, nil, nil]
      end

      context "#current_printing?" do
        it "returns true if the title matches the current printing" do
          parser.stub(:extract_current_printing).and_return("Magic 2014 (Mythic Rare)")
          parser.current_printing?("Magic 2014").should be_true
        end
      end
    end

    context "expansions" do
      it "correctly determines the expansion abbreviation" do
        parser.abbreviation(parser.current_printing.expansion.title).should == "1E"
      end
    end

    it "correctly determines the power" do
      parser.power.should be_nil
    end

    it "correctly determines the toughness" do
      parser.toughness.should be_nil
    end

    context "loyalty" do
      it "correctly determines the loyalty for planeswalkers" do
        parser = Gatherer::CardParser.new(Fixture.html 'nicol_bolas_planeswalker')
        parser.loyalty.should == 5
      end

      it "correctly determines the loyalty for non-planeswalkers" do
        parser.loyalty.should be_nil
      end
    end

    it "correctly determines the illustrator" do
      parser.illustrator.should == "Julie Baroh"
    end
  end

  context "given arbitrary values" do
    let(:parser) { Gatherer::CardParser.new("", false) }

    it "correctly determines the title" do
      parsed_text = "Trogdor, The Burninator                       \n"
      parser.title(parsed_text).should == "Trogdor, The Burninator"
    end

    it "correctly determines the types" do
      parsed_text = "Foofy Pants \u2014 Bananas"
      parser.types(parsed_text).should == ["Foofy", "Pants"]
    end

    it "correctly determines the mana cost" do
      parsed_text = ['Variable Colorless']
      parser.mana_cost(parsed_text).should == "X"
    end

    it "correctly determines the converted mana cost" do
      parsed_text = "\r\n                            1"
      parser.converted_mana_cost(parsed_text).should == 1
    end

    it "correctly determines the subtypes" do
      parsed_text = "Creature \u2014 Kithkin Merfolk Wizard"
      parser.subtypes(parsed_text).should == ["Kithkin", "Merfolk", "Wizard"]
    end

    it "correctly determines the text" do
      parsed_text = ["All mimsy were the borogroves,  \n", "and the momeraths outgrabe."]
      parser.text(parsed_text).should == "All mimsy were the borogroves,\nand the momeraths outgrabe."
    end

    it "correctly determines the flavor text" do
      parsed_text = "Omae no kaachan ha debeso!                   \n"
      parser.flavor_text(parsed_text)
    end

    it "correctly determines the printings" do
      parsed_text = ["Aomori (Apple)", "Fukushima (Peach)"]
      printings = parser.printings(parsed_text)

      titles = printings.map { |printing| printing.expansion.title }

      printings.map(&:rarity).should == ["Apple", "Peach"]
      titles.should == ["Aomori", "Fukushima"]
    end

    context "expansions" do
      it "correctly determines the expansion abbreviation" do
        parsed_text = "../../Handlers/Image.ashx?type=symbol&set=UNH&size=small&rarity=R"
        parser.abbreviation("Unhinged", parsed_text).should == "UNH"
      end
    end

    it "correctly determines the power" do
      parsed_text = "*/*+1"
      parser.power(parsed_text).should == "*"
    end

    it "does not set the power if the text has loyalty" do
      parsed_text = "\r\n                            5"
      parser.power(parsed_text).should == nil
    end

    it "correctly determines the toughness" do
      parsed_text = "*/*+1"
      parser.toughness(parsed_text).should == "*+1"
    end

    it "does not set the toughness if the text has loyalty" do
      parsed_text = "\r\n                            5"
      parser.toughness(parsed_text).should == nil
    end

    it "correctly determines the loyalty" do
      parsed_text = "\r\n                            5"
      parser.loyalty(parsed_text).should == 5
    end

    it "correctly determines the number" do
      parsed_text = "100"
      parser.number(parsed_text).should == 100
    end

    it "correctly determines the illustrator" do
      parsed_text = "Mark Tedin                    \n"
      parser.illustrator(parsed_text).should == "Mark Tedin"
    end
  end

  context "#replace_mana_symbols" do
    let(:parser) { Gatherer::CardParser.new("", false) }

    it "replaces images in html with color placeholders" do
      html = "<div><img alt=\"Purple\" /></div>"
      parser.replace_mana_symbols(html).should == "<div>{{Purple}}</div>"
    end
  end

  context "#to_hash" do
    let(:parser) { Gatherer::CardParser.new(Fixture.html 'magical_hack') }

    it "returns a hash of card attributes" do
      parser.to_hash.should == {
        title: "Magical Hack",
        types: ["Instant"],
        mana_cost: "U",
        converted_mana_cost: 1,
        subtypes: [],
        text: "Change the text of target spell or permanent by replacing all instances of one basic land type with another. (For example, you may change \"swampwalk\" to \"plainswalk.\" This effect lasts indefinitely.)",
        flavor_text: "",
        printings: [
          {expansion: {title: "Limited Edition Alpha", abbreviation: "1E"}, :rarity=>"Rare", :number => 0},
          {expansion: {title: "Limited Edition Beta", abbreviation: "2E"}, :rarity=>"Rare", :number => nil},
          {expansion: {title: "Unlimited Edition", abbreviation: "2U"}, :rarity=>"Rare", :number => nil},
          {expansion: {title: "Revised Edition", abbreviation: "3E"}, :rarity=>"Rare", :number => nil},
          {expansion: {title: "Fourth Edition", abbreviation: "4E"}, :rarity=>"Rare", :number => nil},
          {expansion: {title: "Fifth Edition", abbreviation: "5E"}, :rarity=>"Rare", :number => nil}],
        power: nil,
        toughness: nil,
        loyalty: nil,
        number: 0,
        illustrator: "Julie Baroh"
      }
    end
  end
end
