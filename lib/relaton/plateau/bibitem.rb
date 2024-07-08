require "yaml"

module Relaton
  module Plateau
    class BibItem
      attr_accessor :slug_value, :book_title, :book_description, :book_version,
                    :publication_date, :download_value, :pdf_link, :tags, :book_subtitle

      def initialize(attributes = {})
        attributes.each do |key, value|
          send("#{key}=", value)
        end
      end

      def to_hash
        {
          slug_value: slug_value,
          book_title: book_title,
          book_description: book_description,
          book_version: book_version,
          publication_date: publication_date,
          download_value: download_value,
          pdf_link: pdf_link,
          tags: tags,
          book_subtitle: book_subtitle,
        }.compact
      end

      def to_yaml
        to_hash.to_yaml
      end
    end
  end
end
