module Gatherer
  class CardParser
    attr_reader :document

    SELECTORS = {
      title: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_nameRow',
      types: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_typeRow',
      cmc: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_cmcRow',
      mana: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_manaRow',
      subtypes: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_typeRow',
      text: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_textRow',
      flavor_text: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_flavorRow',
      set: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_setRow',
      other_sets: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_otherSetsRow'
    }

    def initialize(html)
      @document = Nokogiri::HTML(html)
    end

    def title(parsed_text = extract_title)
      parsed_text.strip
    end

    def extract_title
      row = document.css(SELECTORS[:title])
      title_line = row.css('div.value').text
    end

    def types(parsed_text = extract_types)
      [parsed_text.strip.split("\u2014").first.split].flatten
    end

    def extract_types
      row = document.css(SELECTORS[:types])
      type_line = row.css('div.value').text
    end

    def converted_mana_cost(parsed_text = extract_converted_mana_cost)
      parsed_text.strip.to_i
    end

    def extract_converted_mana_cost
      row = document.css(SELECTORS[:cmc])
      cmc_line = row.css('div.value').text
    end

    def mana_cost(parsed_text = extract_mana_cost)
      color_map = Gatherer::Card::COLOR_SYMBOLS
      parsed_text.map { |mana| color_map[mana] ? color_map[mana] : mana }.join
    end

    def extract_mana_cost
      row = document.css(SELECTORS[:mana])
      mana_cost_line = row.css('div.value').css('img').map { |img| img['alt'] }
    end

    def subtypes(parsed_text = extract_subtypes)
      if parsed_text.include?("\u2014")
        parsed_text.split("\u2014").last.split(' ').map { |type| type.strip }
      else
        []
      end
    end

    def extract_subtypes
      row = document.css(SELECTORS[:subtypes])
      row.css('div.value').text
    end

    def text(parsed_text = extract_text)
      parsed_text.map { |line| line.strip }.compact.join("\n")
    end

    def extract_text
      row = document.css(SELECTORS[:text]).first
      row.inner_html = replace_mana_symbols(row.inner_html)
      row.css('div.value div.cardtextbox').map(&:text)
    end

    def replace_mana_symbols(html)
      while image = html.match(/<img.*?alt="([^"]*)"[^>]*>/)
        html.gsub!(image.to_s, "{{#{image.captures.first}}}")
      end

      html
    end

    def flavor_text(parsed_text = extract_flavor_text)
      parsed_text.strip
    end

    def extract_flavor_text
      row = document.css(SELECTORS[:flavor_text])
      row.css('div.cardtextbox').text
    end

    def printings(parsed_text = extract_printings)
      parsed_text.map do |printing|
        Printing.new(
          :expansion => Expansion.new(:title => printing.split(' (').first),
          :rarity => printing.split(' (').last.chop
        )
      end
    end

    def extract_printings
      row = document.css(SELECTORS[:set])
      printing = row.css('img').map { |img| img['title'] }

      row = document.css(SELECTORS[:other_sets])
      other_printings = row.css('img').map { |img| img['title'] }

      (printing + other_printings).uniq
    end
  end
end
