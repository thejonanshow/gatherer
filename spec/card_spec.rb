require "spec_helper"

describe Gatherer::Card do
  it "can be created from html" do
    card = Gatherer::Card.new_from_html(Fixture['magical_hack'])
    card.title.should == 'Magical Hack'
  end
end
