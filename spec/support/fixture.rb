class Fixture
  def self.[](filename)
    File.read("spec/fixtures/#{filename}.html")
  end
end
