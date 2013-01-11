class Fixture
  def self.html(filename)
    File.read("spec/fixtures/#{filename}.html")
  end

  def self.yaml(filename)
    YAML.load(File.read("spec/fixtures/#{filename}.yml"))
  end
end
