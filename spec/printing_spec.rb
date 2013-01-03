describe Gatherer::Printing do
  it "can be created with an expansion and a rarity" do
    mock_expansion = mock(:expansion)
    printing = Gatherer::Printing.new(expansion: mock_expansion, rarity: "Rare")
    printing.expansion.should be mock_expansion
    printing.rarity.should == "Rare"
  end
end
