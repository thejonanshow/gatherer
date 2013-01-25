module Gatherer
  class SplitCardParser
    attr_reader :document, :selectors

    SELECTORS = {
      illustrator: 'div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ctl05_artistRow'
    }

    def initialize(html, validate_card_markup = true)
      @document = Nokogiri::HTML(html)
      @selectors = SELECTORS
      validate if validate_card_markup
    end

    def validate
      raise SplitCardNotFound if find_row(:illustrator).empty?
    end

    def find_row(css)
      document.css(selectors[css])
    end
  end

  class SplitCardNotFound < StandardError
    def initialize
      super("Could not find split card.")
    end
  end
end
