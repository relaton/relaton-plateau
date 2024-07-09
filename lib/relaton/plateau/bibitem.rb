require "yaml"

module Relaton
  module Plateau
    class BibItem
      attr_accessor :pubid, :title_en, :title_jp, :abstract_jp, :edition_number,
                    :edition_text, :cover, :type, :subtype, :filesize,
                    :publication_date, :download_value, :url_pdf, :url_html,
                    :tags

      def initialize(attributes = {})
        attributes.each do |key, value|
          send("#{key}=", value)
        end
      end

      def to_hash
        {
          pubid: pubid,
          title_en: title_en,
          title_jp: title_jp,
          abstract_jp: abstract_jp,
          cover: cover,
          type: type,
          edition_text: edition_text,
          edition_number: edition_number,
          publication_date: publication_date,
          subtype: subtype,
          filesize: filesize,
          url_pdf: url_pdf,
          url_html: url_html,
          tags: tags,
        }.compact
      end

      def encode_with(coder)
        coder.represent_object(nil, to_hash)
      end
    end
  end
end
