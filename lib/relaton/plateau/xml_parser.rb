module Relaton
  module Plateau
    class XMLParser < RelatonBib::XMLParser
      class << self
        private

        #
        # Parse bibitem data
        #
        # @param bibitem [Nokogiri::XML::Element] bibitem element
        #
        # @return [Hash] bibitem data
        #
        def item_data(doc)
          resp = super
          ext = doc.at("./ext")
          return resp unless ext

          resp[:cover] = fetch_cover ext
          resp[:filesize] = fetch_filesize ext
          resp[:stagename] = fetch_stagename ext
          resp
        end

        def fetch_cover(ext)
          img = ext.at("./cover/image")
          return unless img

          Cover.new fetch_image(img)
        end

        def fetch_filesize(elm)
          fs = elm.at("./filesize")
          return unless fs

          fs.text.to_i
        end

        def fetch_stagename(ext)
          sn = ext.at("./stagename")
          return unless sn

          Stagename.new content: sn.text, abbreviation: sn[:abbreviation]
        end

        #
        # override RelatonBib::XMLParser#bib_item method
        #
        # @param item_hash [Hash]
        #
        # @return [RelatonCcsds::BibliographicItem]
        #
        def bib_item(item_hash)
          BibItem.new(**item_hash)
        end

        def create_docid(**args)
          Docidentifier.new(**args)
        end

        def create_doctype(type)
          DocumentType.new type: type.text, abbreviation: type[:abbreviation]
        end
      end
    end
  end
end
