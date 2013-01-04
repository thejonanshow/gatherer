require 'spec_helper'

describe Gatherer::Client do
  context "#fetch_by_multiverse_id" do
    let(:client) { Gatherer::Client.new }
    it "creates a new scraper with a multiverse id" do
      client.stub(:page_from)
      client.stub(:card_from)
      Gatherer::Scraper.should_receive(:new).with(multiverse_id: 1)
      client.fetch_by_multiverse_id(1)
    end

    it "generates a card from the parser" do
      scraper = mock(:scraper)
      client.stub(:scraper).and_return(scraper)
      client.stub(:page_from)

      client.should_receive(:card_from).with scraper
      client.fetch_by_multiverse_id(1)
    end
  end
end
