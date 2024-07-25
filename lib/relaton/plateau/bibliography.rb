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
        rows = index.search { |r| r[:id] ==  code }
        return unless rows.any?

        row = rows.sort_by { |r| r[:id] }.last
        fetch_doc code, **row
      end

      def fetch_doc(code, id:, file:)
        resp = Net::HTTP.get_response URI("#{GHURL}#{file}")
        return unless resp.is_a? Net::HTTPSuccess

        hash = YAML.load(resp.body)
        args = HashConverter.hash_to_bib hash
        BibItem.new(**args)
      end
    end
  end
end
