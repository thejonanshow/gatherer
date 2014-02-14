require 'spec_helper'
require 'gatherer/split_card_parser'

describe Gatherer::SplitCardParser do
  let(:parser) { Gatherer::SplitCardParser.new(Fixture.html('nezumi_shortfang')) }
  let(:expected_rows) { %w(nameRow typeRow cmcRow manaRow setRow numberRow artistRow) }

  it "should raise a card not found error unless given html with a split card" do
    expect { Gatherer::SplitCardParser.new("<div></div>") }.to raise_error Gatherer::SplitCardNotFound
  end

  context "#client_ids" do
    it "should return one selector for each row ID" do
      parser.client_ids.length.should == Gatherer::SplitCardParser::TARGET_ROWS.length
    end
  end

  context "#front_selectors" do
    it "returns a selector for each of the row IDs" do
      selectors = parser.front_selectors.values

      expected_rows.each do |target_row|
        found = selectors.select { |selector| selector.match target_row }
        found.should_not be_empty, "Front selectors do not include selector for #{target_row}"
      end
    end
  end

  context "#back_selectors" do
    it "returns a selector for each of the row IDs" do
      selectors = parser.back_selectors.values

      expected_rows.each do |target_row|
        found = selectors.select { |selector| selector.match target_row }
        found.should_not be_empty, "Back selectors do not include selector for #{target_row}"
      end
    end
  end

  context "#front" do
    let(:card) { parser.front }

    describe "returns the front card from a split card with the correct" do
      it "title" do
        card.title.should == "Nezumi Shortfang"
      end

      it "magic_types" do
        card.magic_types.should == ['Creature']
      end

      it "mana" do
        card.mana_cost.should == '1B'
      end

      it "converted mana cost" do
        card.converted_mana_cost.should == 2
      end

      it "subtypes" do
        card.subtypes.should == ['Rat', 'Rogue']
      end

      it "text" do
        card.text.should == "{{1}}{{Black}}, {{Tap}}: Target opponent discards a card. Then if that player has no cards in hand, flip Nezumi Shortfang.\n"
      end

      it "flavor_text" do
        card.flavor_text.should == nil
      end

      it "set" do
        card.printings.map(&:expansion).map(&:title).should include 'Champions of Kamigawa'
      end

      it "other_sets" do
        card.other_printings.should == []
      end

      it "power" do
        card.power.should == "1"
      end

      it "toughness" do
        card.toughness.should == "1"
      end

      it "number" do
        card.number.should == 131
      end

      it "illustrator" do
        card.illustrator.should == "Daren Bader"
      end
    end
  end

  context "#back" do
    let(:parser) { Gatherer::SplitCardParser.new(Fixture.html('nezumi_shortfang')) }
    let(:card) { parser.back }

    describe "returns the front card from a split card with the correct" do
      it "title" do
        card.title.should == "Stabwhisker the Odious"
      end

      it "magic_types" do
        card.magic_types.should == ['Legendary', 'Creature']
      end

      it "mana" do
        card.mana_cost.should == '1B'
      end

      it "converted mana cost" do
        card.converted_mana_cost.should == 2
      end

      it "subtypes" do
        card.subtypes.should == ['Rat', 'Shaman']
      end

      it "text" do
        card.text.should == "At the beginning of each opponent's upkeep, that player loses 1 life for each card fewer than three in his or her hand."
      end

      it "flavor_text" do
        card.flavor_text.should == nil
      end

      it "set" do
        card.printings.map(&:expansion).map(&:title).should include 'Champions of Kamigawa'
      end

      it "other_sets" do
        card.other_printings.should == []
      end

      it "power" do
        card.power.should == "3"
      end

      it "toughness" do
        card.toughness.should == "3"
      end

      it "number" do
        card.number.should == 131
      end

      it "illustrator" do
        card.illustrator.should == "Daren Bader"
      end
    end
  end
end
