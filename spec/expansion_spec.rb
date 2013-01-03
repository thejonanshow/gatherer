describe Gatherer::Expansion do
  it "can be created with a title" do
    expansion = Gatherer::Expansion.new(title: "Phelddagrif")
    expansion.title.should == "Phelddagrif"
  end
end
