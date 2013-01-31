module Gatherer
  class CardParser
    attr_reader :document
    attr_accessor :selectors

    DEFAULT_SELECTORS = {
      title: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_nameRow',
      types: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_typeRow',
      cmc: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_cmcRow',
      mana: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_manaRow',
      subtypes: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_typeRow',
      text: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_textRow',
      flavor_text: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_flavorRow',
      set: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_setRow',
      other_sets: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_otherSetsRow',
      pt: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ptRow',
      number: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_numberRow',
      illustrator: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_artistRow'
    }

    def initialize(html, validate_card_markup = true)
      @document = Nokogiri::HTML(html)
      @selectors = DEFAULT_SELECTORS
      validate if validate_card_markup
    end

    def validate
      raise CardNotFound if find_row(:illustrator).empty?
    end

    def find_row(css)
      document.css(selectors[css])
    end

    def title(parsed_text = extract_title)
      parsed_text.strip
    end

    def extract_title
      row = find_row(:title)
      title_line = row.css('div.value').text if row
    end

    def types(parsed_text = extract_types)
      if parsed_text
        types = parsed_text.strip.split("\u2014").first
        types.split.flatten
      end
    end

    def extract_types
      row = find_row(:types)
      row.css('div.value').text unless row.empty?
    end

    def converted_mana_cost(parsed_text = extract_converted_mana_cost)
      parsed_text.strip.to_i if parsed_text
    end

    def extract_converted_mana_cost
      row = find_row(:cmc)
      cmc_line = row.css('div.value').text unless row.empty?
    end

    def mana_cost(parsed_text = extract_mana_cost)
      color_map = Gatherer::Card::COLOR_SYMBOLS
      parsed_text.map { |mana| color_map[mana] ? color_map[mana] : mana }.join
    end

    def extract_mana_cost
      row = find_row(:mana)

      if row
        mana_cost_line = row.css('div.value').css('img').map { |img| img['alt'] }
      end
    end

    def subtypes(parsed_text = extract_subtypes)
      if parsed_text && parsed_text.include?("\u2014")
        parsed_text.split("\u2014").last.split(' ').map { |type| type.strip }
      else
        []
      end
    end

    def extract_subtypes
      row = find_row(:subtypes)
      row.css('div.value').text unless row.empty?
    end

    def text(parsed_text = extract_text)
      parsed_text.map { |line| line.strip }.compact.join("\n") if parsed_text
    end

    def extract_text
      row = find_row(:text)

      unless row.empty?
        text_element = row.first
        text_element.inner_html = replace_mana_symbols(text_element.inner_html)
        text_element.css('div.value div.cardtextbox').map(&:text)
      end
    end

    def replace_mana_symbols(html)
      while image = html.match(/<img.*?alt="([^"]*)"[^>]*>/)
        html.gsub!(image.to_s, "{{#{image.captures.first}}}")
      end

      html
    end

    def flavor_text(parsed_text = extract_flavor_text)
      parsed_text.strip if parsed_text
    end

    def extract_flavor_text
      row = find_row(:flavor_text)
      row.css('div.cardtextbox').text unless row.empty?
    end

    def parse_printing(printing)
      if printing
        title = printing.split(' (').first
        Printing.new(
          expansion: Expansion.new(title: title, abbreviation: abbreviation(title)),
          rarity: printing.split(' (').last.chop,
          number: (number if current_printing?(title))
        )
      end
    end

    def printings(parsed_text = extract_printings)
      parsed_text.map do |printing|
        parse_printing(printing)
      end
    end

    def extract_printings
      ([extract_current_printing] + extract_other_printings).uniq
    end

    def current_printing(parsed_text = extract_current_printing)
      parse_printing(parsed_text) if parsed_text
    end

    def current_printing?(title)
      current_printing_text = extract_current_printing
      current_title = current_printing_text.split(' (').first if current_printing_text
      title == current_title
    end

    def extract_current_printing
      row = find_row(:set)
      row.css('img').map { |img| img['title'] }.first unless row.empty?
    end

    def other_printings(parsed_text = extract_other_printings)
      parsed_text.map do |printing|
        Printing.new(
          expansion: Expansion.new(:title => parsed_text.split(' (').first),
          rarity: parsed_text.split(' (').last.chop
        )
      end
    end

    def extract_other_printings
      row = find_row(:other_sets)
      row.css('img').map { |img| img['title'] } if row
    end

    def abbreviation(title, parsed_text = nil)
      parsed_text ||= extract_abbreviation(title)
      parsed_text.split('&set=').last.split('&').first if parsed_text
    end

    def extract_abbreviation(title)
      images = find_row(:set).css('img')

      unless images.empty?
        images += document.css(selectors[:other_sets]).css('img')

        images.map do |image|
          image['src'] if image['title'].include?(title)
        end.compact.uniq.first
      end
    end

    def power(parsed_text = extract_power_toughness)
      parsed_text.split('/').first.strip if parsed_text && parsed_text.include?('/')
    end

    def toughness(parsed_text = extract_power_toughness)
      parsed_text.split('/').last.strip if parsed_text && parsed_text.include?('/')
    end

    def extract_power_toughness
      row = find_row(:pt)
      row.css('div.value').text unless row.empty?
    end

    # gatherer uses the pt row to display loyalty
    def loyalty(parsed_text = extract_power_toughness)
      if parsed_text && !parsed_text.include?('/')
        parsed_text.to_i if parsed_text.to_i > 0
      end
    end

    def number(parsed_text = extract_number)
      parsed_text.to_i
    end

    def extract_number
      row = find_row(:number)
      row.css('div.value').text unless row.empty?
    end

    def illustrator(parsed_text = extract_illustrator)
      parsed_text.strip if parsed_text
    end

    def extract_illustrator
      row = find_row(:illustrator)
      row.css('div.value').text unless row.empty?
    end

    def to_hash
      {
        title: title,
        types: types,
        mana_cost: mana_cost,
        converted_mana_cost: converted_mana_cost,
        subtypes: subtypes,
        text: text,
        flavor_text: flavor_text,
        printings: printings.map(&:to_hash),
        power: power,
        toughness: toughness,
        loyalty: loyalty,
        number: number,
        illustrator: illustrator
      }
    end
  end

  class CardNotFound < StandardError
    def initialize
      super("Could not find card.")
    end
  end
end
