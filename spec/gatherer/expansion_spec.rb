require 'spec_helper'

describe Gatherer::Expansion do
  it "can be created with a title" do
    expansion = Gatherer::Expansion.new(title: "Phelddagrif")
    expansion.title.should == "Phelddagrif"
  end

  it "can be created with an abbreviation" do
    expansion = Gatherer::Expansion.new(abbreviation: "DRP")
    expansion.abbreviation.should == "DRP"
  end
end
