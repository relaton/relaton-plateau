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

        hash_to_bib_cover ret
        hash_to_bib_filesize ret
        hash_to_bib_stagename ret
        ret.delete :ext
        ret
      end

      def hash_to_bib_cover(ret)
        return unless ret[:ext][:cover]

        image = ret[:ext][:cover][:image]
        ret[:cover] = Cover.new(RelatonBib::Image.new(**image))
      end

      def hash_to_bib_filesize(ret)
        return unless ret[:ext][:filesize]

        ret[:filesize] = ret[:ext][:filesize].to_i
      end

      def hash_to_bib_stagename(ret)
        return unless ret[:ext][:stagename]

        ret[:stagename] = Stagename.new(**ret[:ext][:stagename])
      end

      # @param item_hash [Hash]
      # @return [RelatonCie::BibliographicItem]
      def bib_item(item_hash)
        BibItem.new(**item_hash)
      end

      def create_docid(**args)
        Docidentifier.new(**args)
      end

      def create_doctype(**args)
        DocumentType.new(**args)
      end
    end
  end
end
