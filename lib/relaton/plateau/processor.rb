require "relaton/processor"

module Relaton
  module Plateau
    class Processor < Relaton::Processor
      attr_reader :idtype

      def initialize # rubocop:disable Lint/MissingSuper
        @short = :"relaton/plateau"
        @prefix = "PLATEAU"
        @defaultprefix = /^PLATEAU\s/
        @idtype = "PLATEAU"
        @datasets = %w[plateau-handbooks plateau-technical-reports]
      end

      # @param code [String]
      # @param date [String, nil] year
      # @param opts [Hash]
      # @return [Relaton::Plateau::BibliographicItem
      def get(code, date, opts)
        ::Relaton::Plateau::Bibliography.get(code, date, opts)
      end

      #
      # Fetch all the documents from www.mlit.go.jp/plateau
      #
      # @param [String] source source name (plateau-handbooks, paleteau-technical-reports)
      # @param [Hash] opts
      # @option opts [String] :output directory to output documents
      # @option opts [String] :format output format (xml, yaml, bibxml)
      #
      def fetch_data(source, opts)
        Fetcher.fetch(source, **opts)
      end

      # @param xml [String]
      # @return [Relaton::Plateau::BibItem]
      def from_xml(xml)
        ::Relaton::Plateau::XMLParser.from_xml xml
      end

      # @param hash [Hash]
      # @return [Relaton:Plateau::BibItem]
      def hash_to_bib(hash)
        item_hash = HashConverter.hash_to_bib(hash)
        ::Relaton::Plateau::BibItem.new(**item_hash)
      end

      # Returns hash of XML grammar
      # @return [String]
      def grammar_hash
        @grammar_hash ||= ::Relaton::Plateau.grammar_hash
      end

      # Returns number of workers
      # @return [Integer]
      def threads
        3
      end

      #
      # Remove index file
      #
      def remove_index_file
        Relaton::Index.find_or_create(:plateau, url: true, file: "#{Bibliography::INDEXFILE}.yaml").remove_file
      end
    end
  end
end
