module Gatherer
  class SplitCardParser
    attr_reader :page, :document, :selectors

    DEFAULT_SELECTORS = {
      illustrator: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ctl05_artistRow'
    }
    FRONT_SELECTORS = {
      title: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ctl05_nameRow',
      types: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ctl05_typeRow',
      cmc: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ctl05_cmcRow',
      mana: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ctl05_manaRow',
      subtypes: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ctl05_typeRow',
      text: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ctl05_textRow',
      flavor_text: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ctl05_flavorRow',
      set: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ctl05_setRow',
      other_sets: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ctl05_otherSetsRow',
      pt: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ctl05_ptRow',
      number: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ctl05_numberRow',
      illustrator: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ctl05_artistRow'
    }
    BACK_SELECTORS = {
      title: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ctl06_nameRow',
      types: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ctl06_typeRow',
      cmc: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ctl06_cmcRow',
      mana: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ctl06_manaRow',
      subtypes: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ctl06_typeRow',
      text: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ctl06_textRow',
      flavor_text: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ctl06_flavorRow',
      set: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ctl06_setRow',
      other_sets: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ctl06_otherSetsRow',
      pt: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ctl06_ptRow',
      number: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ctl06_numberRow',
      illustrator: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ctl06_artistRow'
    }

    def initialize(html, validate_card_markup = true)
      @page = html
      @document = Nokogiri::HTML(page)
      @selectors = DEFAULT_SELECTORS
      validate if validate_card_markup
    end

    def validate
      raise SplitCardNotFound if find_row(:illustrator).empty?
    end

    def find_row(css)
      document.css(selectors[css])
    end

    def front
      parser = Gatherer::CardParser.new(page, false)
      parser.selectors = FRONT_SELECTORS
      parser.validate
      parser
    end

    def back
      parser = Gatherer::CardParser.new(page, false)
      parser.selectors = BACK_SELECTORS
      parser.validate
      parser
    end
  end

  class SplitCardNotFound < StandardError
    def initialize
      super("Could not find split card.")
    end
  end
end
