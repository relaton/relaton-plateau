module Relaton
  module Plateau
    module Bibliography
      extend self

      INDEXFILE = "index-v1"
      GHURL = "https://raw.githubusercontent.com/relaton/relaton-data-plateau/main/"

      def index
        Relaton::Index.find_or_create :plateau, url: "#{GHURL}#{INDEXFILE}.zip", file: "#{INDEXFILE}.yaml"
      end

      def get(code, year = nil, opts = {})
        Util.info "Fetching ...", key: code
        bib = search(code)
        if bib
          Util.info "Found `#{bib.docidentifier.first.id}`", key: code
          bib
        else
          Util.warn "Not found.", key: code
        end
      rescue StandardError => e
        raise RelatonBib::RequestError, e.message
      end

      def search(code)
        all_editions = code.match?(/ #\d+$/)
        rows = index.search do |r|
          id = all_editions ? r[:id].sub(/ \d+\.\d+$/, "") : r[:id]
          id ==  code
        end
        return unless rows.any?

        hits = rows.map { |r| Hit.new(**r) }
        all_editions ? hits[0].bibitem.to_all_editions(hits) : hits[0].bibitem
      end
    end
  end
end
