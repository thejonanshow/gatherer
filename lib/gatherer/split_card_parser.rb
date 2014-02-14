module Gatherer
  class SplitCardParser
    attr_reader :page, :document, :selectors

    TARGET_ROWS = %w(nameRow typeRow cmcRow manaRow textRow flavorRow setRow otherSetsRow ptRow numberRow artistRow)
    def front_selectors
      build_selectors(client_ids)
    end

    def back_selectors
      build_selectors(back_ids)
    end

    def build_selectors(scraped_ids)
      attribute_row_names = {
        title: 'nameRow',
        magic_types: 'typeRow',
        cmc: 'cmcRow',
        mana: 'manaRow',
        subtypes: 'typeRow',
        text: 'textRow',
        flavor_text: 'flavorRow',
        set: 'setRow',
        other_sets: 'otherSetsRow',
        pt: 'ptRow',
        number: 'numberRow',
        illustrator: 'artistRow'
      }

      selectors = {}
      attribute_row_names.each do |attribute, row|
        if scraped_id = scraped_ids[row]
          selectors[attribute] = 'div#' + scraped_ids[row]
        end
      end

      selectors
    end

    def back_ids
      potential_back_ids = document_row_ids - client_ids.values
      matched_ids = {}

      TARGET_ROWS.each do |target_row|
        potential_back_ids.each do |back_id|
          if back_id.match target_row
            matched_ids[target_row] = back_id
          end
        end
      end

      matched_ids
    end

    def document_row_ids
      self.document.css('div.row').map { |el| el.attribute('id').value }
    end

    def self.id_from_client_id(target_document, client_id)
      line = client_id_lines(target_document).select { |line| line.match client_id }.first
      line.split(" = '").last.split("'").first if line
    end

    def self.client_id_lines(target_document)
      client_id_script_tag = target_document.search('script').select do |script_tag|
        script_tag.text.include? 'ClientIDs'
      end

      return [] if client_id_script_tag.empty?

      client_id_script_tag.first.text.split("\n").select do |line|
        line.include?('ClientIDs')
      end
    end

    def client_ids
      client_id_lines = SplitCardParser.client_id_lines(self.document)

      selectors = {}

      TARGET_ROWS.each do |target_row|
        client_id_lines.each do |line|
          if line.match target_row
            selectors[target_row] = line.split(" = '").last.split("'").first
          end
        end
      end

      selectors
    end

    def initialize(html, validate_card_markup = true)
      @page = html
      @document = Nokogiri::HTML(page)
      validate if validate_card_markup
    end

    def validate
      # A split card page should have two non-blank card names
      has_front_title = front_selectors[:title] && !front_selectors[:title].empty?
      has_back_title = back_selectors[:title] && !back_selectors[:title].empty?

      raise SplitCardNotFound unless has_front_title && has_back_title
    end

    def find_row(css)
      document.css(selectors[css])
    end

    def front
      parser = Gatherer::CardParser.new(page, false)
      parser.selectors = front_selectors
      parser.validate
      parser
    end

    def back
      parser = Gatherer::CardParser.new(page, false)
      parser.selectors = back_selectors
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
