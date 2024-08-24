# encoding: UTF-8

module Relaton
  module Plateau
    class HandbookParser < Parser
      def initialize(version:, entry:, title_en:, abstract:, doctype:)
        @version = version
        @entry = entry
        super entry["handbook"]
        @title_en = title_en
        @abstract = abstract
        @doctype = doctype
      end

      private

      def edition
        @edition ||= @version["title"].split.first.match(/[\d.]+/).to_s
      end

      def parse_docnumber
        "Handbook ##{@entry["slug"]} #{edition}"
      end

      def parse_title
        title = super
        title << create_title(@title_en, "en", "Latn") if @title_en
        title
      end

      def parse_abstract
        abstr = super
        abstr << create_formatted_string(@abstract) if @abstract
        abstr
      end

      def parse_edition
        number = edition.match(/\d\.\d/)[0]
        RelatonBib::Edition.new(content: edition, number: number)
      end

      def parse_doctype
        DocumentType.new type: @doctype
      end

      def parse_date
        super << create_date(@version["date"].gsub(".", "-"))
      end

      def parse_link
        %w[pdf html].map do |type|
          next unless @version[type]

          create_link(@version[type], type)
        end.compact
      end

      def parse_filesize
        @version["filesize"].to_i
      end

      def parse_structuredidentifier
        strid = RelatonBib::StructuredIdentifier.new(
          type: "Handbook", agency: ["PLATEAU"], docnumber: @entry["slug"], edition: edition
        )
        RelatonBib::StructuredIdentifierCollection.new [strid]
      end
    end
  end
end
