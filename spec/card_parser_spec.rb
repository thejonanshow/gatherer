require 'spec_helper'
require 'gatherer/card_parser'

describe Gatherer::CardParser do
  context "given html" do
    let(:parser) { Gatherer::CardParser.new(Fixture['magical_hack']) }

    it "correctly determines the title" do
      parser.title.should == "Magical Hack"
    end

    it "correctly determines the types" do
      parser.types.should == ['Instant']
    end

    it "correctly determines the mana cost" do
      parser.mana_cost.should == "U"
    end

    it "correctly determines the converted mana cost" do
      parser.converted_mana_cost.should == 1
    end

    it "correctly determines the subtypes" do
      parser.subtypes.should == []
    end

    it "correctly determines the text" do
      parser.text.should == "Change the text of target spell or permanent by replacing all instances of one basic land type with another. (For example, you may change \"swampwalk\" to \"plainswalk.\" This effect lasts indefinitely.)"
    end

    it "correctly determines the flavor text" do
      parser.flavor_text.should == ""
    end

    it "correctly determines the printings" do
      titles = parser.printings.map { |printing| printing.expansion.title }

      titles.should == ["Limited Edition Alpha", "Limited Edition Beta", "Unlimited Edition", "Revised Edition", "Fourth Edition", "Fifth Edition"]
      parser.printings.map(&:rarity).uniq.should == ["Rare"]
    end
  end

  context "given arbitrary values" do
    let(:parser) { Gatherer::CardParser.new("") }

    it "correctly determines the title" do
      parsed_text = "Trogdor, The Burninator                       \n"
      parser.title(parsed_text).should == "Trogdor, The Burninator"
    end

    it "correctly determines the types" do
      parsed_text = "Foofy Pants \u2014 Bananas"
      parser.types(parsed_text).should == ["Foofy", "Pants"]
    end

    it "correctly determines the mana cost" do
      parsed_text = ['Variable Colorless']
      parser.mana_cost(parsed_text).should == "X"
    end

    it "correctly determines the converted mana cost" do
      parsed_text = "\r\n                            1"
      parser.converted_mana_cost(parsed_text).should == 1
    end

    it "correctly determines the subtypes" do
      parsed_text = "Creature \u2014 Kithkin Merfolk Wizard"
      parser.subtypes(parsed_text).should == ["Kithkin", "Merfolk", "Wizard"]
    end

    it "correctly determines the text" do
      parsed_text = ["All mimsy were the borogroves,  \n", "and the momeraths outgrabe."]
      parser.text(parsed_text).should == "All mimsy were the borogroves,\nand the momeraths outgrabe."
    end

    it "correctly determines the flavor text" do
      parsed_text = "Omae no kaachan ha debeso!                   \n"
      parser.flavor_text(parsed_text)
    end

    it "correctly determines the printings" do
      parsed_text = ["Aomori (Apple)", "Fukushima (Peach)"]
      printings = parser.printings(parsed_text)

      titles = printings.map { |printing| printing.expansion.title }

      printings.map(&:rarity).should == ["Apple", "Peach"]
      titles.should == ["Aomori", "Fukushima"]
    end
  end

  context "#replace_mana_symbols" do
    let(:parser) { Gatherer::CardParser.new("") }

    it "replaces images in html with color placeholders" do
      html = "<div><img alt=\"Purple\" /></div>"
      parser.replace_mana_symbols(html).should == "<div>{{Purple}}</div>"
    end
  end
end

require 'open-uri'
require 'nokogiri'

BASE_PATH = 'http://gatherer.wizards.com'

class Seeker
  attr_accessor :path

  def initialize(path = BASE_PATH)
    @path = path
  end

  def all_expansion_titles
    homepage = Nokogiri::HTML(file_from_id(0))
    set_select = homepage.css("select#ctl00_ctl00_MainContent_Content_SearchControls_setAddText")
    set_select.css("option").map { |option| option[:value] unless option[:value].empty? }.compact
  end

  def expansion_abbreviation(title)
    expansion_page = Nokogiri::HTML(file_from_expansion_title(title))

    current_set = expansion_page.css("div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ctl00_listRepeater_ctl00_cardSetCurrent")
    current_set.css('img').first[:src].split('set=').last.split('&').first unless current_set.empty?
  end

  def find(multiverse_id)
    file = file_from_id(multiverse_id)

    if intro_page?(file)
      raise CardNotFoundError, "No card with multiverse_id #{multiverse_id}"
    else
      parse_card_from(file)
    end
  end

  def intro_page?(file)
    document = Nokogiri::HTML(file)
    intro_text = document.css("div#ctl00_ctl00_gathererIntroText").text
    file.rewind if file.respond_to? :rewind
    intro_text != ""
  end

  def file_from_id(id)
    if @path =~ URI::ABS_URI
      open("#{path + '/Pages/Card/Details.aspx?multiverseid='}#{id}")
    else
      File.read("#{path}#{id}")
    end
  end

  def file_from_expansion_title(title)
    if @path =~ URI::ABS_URI
      open("#{path + URI.encode("/Pages/Search/Default.aspx?set=[\"#{title}\"]")}")
    else
      filename = "#{path}#{title.downcase.gsub(/[^\w]/,'_')}"
      File.read filename if File.exists? filename
    end
  end

  def parse_card_from(file)
    card = Card.new
    document = Nokogiri::HTML(file)

    card.instance_variables.each do |attribute|
      attribute = attribute.to_s[1..-1]
      card.send("#{attribute}=", self.send("#{attribute}_from", document))
    end

    card
  end

  def title_from(document)
    row = document.css('div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_nameRow')
    row.css('div.value').text.strip
  end


  def converted_mana_cost_from(document)
    row = document.css('div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_cmcRow')
    row.css('div.value').text.strip.to_i
  end

  def type_from(document)
    row = document.css('div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_typeRow')
    row.css('div.value').text.split("\u2014").first.strip
  end

  def subtypes_from(document)
    row = document.css('div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_typeRow')
    types_and_subtypes = row.css('div.value').text
    if types_and_subtypes.include?("\u2014")
      types_and_subtypes.split("\u2014").last.split(' ').map { |type| type.strip }
    else
      []
    end
  end

  def text_from(document)
    row = document.css('div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_textRow').first
    row = replace_mana_symbols(row)
    lines = row.css('div.value div.cardtextbox')
    lines.map { |line| line.text.strip }.compact.join("\n")
  end

  def flavor_text_from(document)
    row = document.css('div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_flavorRow')
    row.css('div.cardtextbox').text
  end

  def replace_mana_symbols(row)
    row_html = row.inner_html

    while image = row_html.match(/<img.*?alt="([^"]*)"[^>]*>/)
      row_html.gsub!(image.to_s, "{{#{image.captures.first}}}")
    end

    row.inner_html = row_html
    row
  end

  def power_from(document)
    row = document.css('div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ptRow')
    pt_text = row.css('div.value').text
    pt_text.split('/').first.to_i unless pt_text.empty?
  end

  def toughness_from(document)
    row = document.css('div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ptRow')
    pt_text = row.css('div.value').text
    pt_text.split('/').last.to_i unless pt_text.empty?
  end

  def rarities_from(document)
    row = document.css('div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_rarityRow')
    row.css('div.value').text.strip
  end

  def number_from(document)
    row = document.css('div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_numberRow')
    row.css('div.value').text.to_i
  end

  def illustrator_from(document)
    row = document.css('div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_artistRow')
    row.css('div.value').text.strip
  end

  def printings_from(document)
    row = document.css('div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_setRow')
    printing = row.css('img').map { |img| img['title'] }

    row = document.css('div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_otherSetsRow')
    other_printings = row.css('img').map { |img| img['title'] }

    (printing + other_printings).map do |printing|
      Printing.new(
        :expansion => Expansion.new(:title => printing.split(' (').first),
        :rarity => printing.split(' (').last.chop
      )
    end
  end

  def expansions_from(document)
    row = document.css('div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_setRow')
    expansion = row.css('img').map { |img| img['title'].split(/\(.+\)/).first.strip }

    row = document.css('div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_otherSetsRow')
    other_expansions = row.css('img').map { |img| img['title'].split(/\(.+\)/).first.strip }

    (expansion + other_expansions).uniq.map do |exp|
      Expansion.new(:title => exp)
    end
  end
end

class CardNotFoundError < StandardError
end
