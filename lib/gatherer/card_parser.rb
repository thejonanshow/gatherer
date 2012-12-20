module Gatherer
  module CardParser
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def new_from_html(html)
        card = extract_card(html)

        Gatherer::Card.new(
          title: card[:title]
        )
      end

      def extract_card(html)
        doc = Nokogiri::HTML(html)

        {
          title: extract_title(doc)
        }
      end

      def extract_title(doc)
        row = doc.css('div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_nameRow')
        row.css('div.value').text.strip
      end
    end
  end
end
