module Relaton
  module Plateau
    class Hit
      def initialize(**args)
        @id = args[:id]
        @file = args[:file]
      end

      def bibitem
        return @bibitem if defined? @bibitem
        @bibitem = fetch_doc
      end

      private

      def fetch_doc
        resp = Net::HTTP.get_response URI("#{Bibliography::GHURL}#{@file}")
        return unless resp.is_a? Net::HTTPSuccess

        hash = YAML.load(resp.body)
        args = HashConverter.hash_to_bib hash
        args[:fetched] = Date.today.to_s
        BibItem.new(**args)
      end
    end
  end
end
