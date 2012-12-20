require "spec_helper"

describe Gatherer::Scraper do
  describe "#url" do
    it "is created with a valid url" do
      Gatherer::Scraper.new.url.should be_valid_url
    end

    it "is created with a valid url given a set filter" do
      gatherer = Gatherer::Scraper.new(:set => "Urza's Saga")
      gatherer.url.should be_valid_url
    end

    it "is created with a valid url given page number" do
      gatherer = Gatherer::Scraper.new(:page => 1)
      gatherer.url.should be_valid_url
    end

    it "is created with a valid url given a multiverse id" do
      gatherer = Gatherer::Scraper.new(:multiverse_id => 1)
      gatherer.url.should be_valid_url
    end

    it "is created with a valid url given multiple parameters" do
      gatherer = Gatherer::Scraper.new(
        :page => 1,
        :set => "Return to Ravnica",
        :multiverse_id => 1
      )

      gatherer.url.should be_valid_url
    end
  end
end
