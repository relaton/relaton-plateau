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
        rows = index.search(code)
        return if rows.empty?

        row = rows.sort_by { |r| r[:id] }.last
        get_doc code, **row
      rescue StandardError => e
        raise RelatonBib::RequestError, e.message
      end

      def get_doc(code, id:, file:)
        resp = Net::HTTP.get_response URI("#{GHURL}#{file}")
        if resp.is_a? Net::HTTPSuccess
          Util.info "Found `#{id}`", key: code
          hash = YAML.load(resp.body)
          args = HashConverter.hash_to_bib hash
          BibItem.new(**args)
        else
          Util.warn "Failed to fetch.", key: code
        end
      end
    end
  end
end
