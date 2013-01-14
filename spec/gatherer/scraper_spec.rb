require "spec_helper"

describe Gatherer::Scraper do
  context "#url" do
    it "is created with a valid url" do
      Gatherer::Scraper.new.url.should be_valid_url
    end

    it "is created with a valid url given an expansion filter" do
      gatherer = Gatherer::Scraper.new(:expansion => "Urza's Saga")
      gatherer.url.should be_valid_url
    end

    it "is created with the search default url using an expansion filter" do
      gatherer = Gatherer::Scraper.new(:expansion => "Return to Ravnica")
      gatherer.url.should include '/Pages/Search/Default.aspx'
    end

    it "includes escaped quotes in the expansion url" do
      gatherer = Gatherer::Scraper.new(:expansion => "Return to Ravnica")
      gatherer.url.should include '%22'
    end

    it "is created with a valid url given page number" do
      gatherer = Gatherer::Scraper.new(:page => 1)
      gatherer.url.should be_valid_url
    end

    it "is created with a valid url given a multiverse id" do
      gatherer = Gatherer::Scraper.new(:multiverse_id => 1)
      gatherer.url.should be_valid_url
    end

    it "is created with the page detail url given a multiverse id" do
      gatherer = Gatherer::Scraper.new(:multiverse_id => 1)
      gatherer.url.should include("/Pages/Card/Details.aspx")
    end

    it "is created with a valid url given multiple parameters" do
      gatherer = Gatherer::Scraper.new(
        :page => 1,
        :expansion => "Return to Ravnica",
        :multiverse_id => 1
      )

      gatherer.url.should be_valid_url
    end
  end
end
