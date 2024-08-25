module Relaton
  module Plateau
    class TechnicalReportParser < Parser
      def initialize(entry)
        @entry = entry
        super entry["technicalReport"]
      end

      private

      def parse_docnumber
        "Technical Report ##{@entry["slug"]} #{edition_number}"
      end

      def parse_abstract
        super << create_formatted_string(@item["subtitle"])
      end

      def parse_edition
        RelatonBib::Edition.new content: edition_number, number: edition_number
      end

      def edition_number
        "1.0"
      end

      def parse_doctype
        DocumentType.new type: "technical-report"
      end

      def parse_subdoctype
        @entry["technicalReportCategories"]["nodes"].dig(0, "name")
      end

      def parse_date
        super << create_date(@entry["date"])
      end

      def parse_link
        super << create_link(@item["pdf"], "pdf")
      end

      def parse_filesize
        @item["filesize"].to_i
      end

      def parse_keyword
        @entry["globalTags"]["nodes"].map { |tag| tag["name"] }
      end

      def parse_structuredidentifier
        strid = RelatonBib::StructuredIdentifier.new(
          type: "Technical Report", class: parse_subdoctype, agency: ["PLATEAU"], docnumber: @entry["slug"]
        )
        RelatonBib::StructuredIdentifierCollection.new [strid]
      end
    end
  end
end
