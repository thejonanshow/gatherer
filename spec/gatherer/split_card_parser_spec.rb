require 'spec_helper'
require 'gatherer/split_card_parser'

describe Gatherer::SplitCardParser do
  it "should raise a card not found error unless given html with a split card" do
    expect { Gatherer::SplitCardParser.new("<div></div>") }.to raise_error Gatherer::SplitCardNotFound
  end
end
