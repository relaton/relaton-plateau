require "yaml"

module Relaton
  module Plateau
    class BibItem
      attr_accessor :pubid, :title, :abstract, :edition_number, :edition_text,
                    :cover, :type, :subtype, :filesize, :publication_date,
                    :download_value, :pdf_link, :tags

      def initialize(attributes = {})
        attributes.each do |key, value|
          send("#{key}=", value)
        end
      end

      def to_hash
        {
          pubid: pubid,
          title: title,
          abstract: abstract,
          cover: cover,
          type: type,
          edition_text: edition_text,
          edition_number: edition_number,
          publication_date: publication_date,
          subtype: subtype,
          filesize: filesize,
          pdf_link: pdf_link,
          tags: tags,
        }.compact
      end

      def to_yaml
        to_hash.to_yaml
      end
    end
  end
end
