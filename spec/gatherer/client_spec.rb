require 'spec_helper'

describe Gatherer::Client do
  let(:client) { Gatherer::Client.new }

  context "#fetch_by_multiverse_id" do
    it "creates a new scraper with a multiverse id" do
      client.stub(:page_from)
      client.stub(:card_from)
      Gatherer::Scraper.should_receive(:new).with(multiverse_id: 1)
      client.fetch_by_multiverse_id(1)
    end

    it "generates a card from the parser" do
      scraper = mock(:multiverse_scraper)
      client.stub(:multiverse_scraper).and_return(scraper)
      client.stub(:page_from)

      client.should_receive(:card_from).with scraper
      client.fetch_by_multiverse_id(1)
    end
  end

  context "#expansions" do
    let(:expansions) { client.expansions(Fixture.html('homepage'), Fixture.html('return_to_ravnica')) }

    it "returns a collection of expansions with titles" do
      Fixture.yaml('expansions').each do |exp|
        expansions.map(&:title).should include exp.title
      end
    end

    it "returns a collections of expansions with abbreviations" do
      expansions.map(&:abbreviation).should include "RTR"
    end
  end

  context "#expansion_abbreviation_for" do
    it "returns the expansion abbreviation for a given title" do
      abbr = client.expansion_abbreviation_for("Return to Ravnica", Fixture.html('return_to_ravnica'))
      abbr.should == "RTR"
    end
  end
end
