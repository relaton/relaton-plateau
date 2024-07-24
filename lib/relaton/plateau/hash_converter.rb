module Relaton
  module Plateau
    module HashConverter
      include RelatonBib::HashConverter
      extend self
      # @param args [Hash]
      # @return [Hash]
      def hash_to_bib(args)
        ret = super
        return unless ret
        return ret unless ret[:ext]

        ext = ret[:ext]
        hash_to_bib_cover ext
        hash_to_bib_filesize ext
        hash_to_bib_stagename ext
        ret
      end

      def hash_to_bib_cover(ext)
        return unless ext[:cover]

        image = ext[:cover][:image]
        ext[:cover] = Cover.new(RelatonBib::Image.new(**image))
      end

      def hash_to_bib_filesize(ext)
        return unless ext[:filesize]

        ext[:filesize] = ext[:filesize].to_i
      end

      def hash_to_bib_stagename(ext)
        return unless ext[:stagename]

        ext[:stagename] = Stagename.new(**ext[:stagename])
      end

      # @param item_hash [Hash]
      # @return [RelatonCie::BibliographicItem]
      def bib_item(item_hash)
        BibliographicItem.new(**item_hash)
      end

      def create_doctype(**args)
        DocumentType.new(**args)
      end
    end
  end
end
