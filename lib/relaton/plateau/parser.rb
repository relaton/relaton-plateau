module Relaton
  module Plateau
    # Base class for Plateau parsers
    class Parser
      ATTRIS = %i[docid docnumber title abstract cover edition type doctype subdoctype
                  date link contributor filesize keyword structuredidentifier].freeze

      def initialize(item)
        @item = item
      end

      def parse
        args = ATTRIS.each_with_object({}) do |attr, hash|
          hash[attr] = send("parse_#{attr}")
        end
        BibItem.new(**args)
      end

      private

      def parse_docid
        [create_docid("PLATEAU #{parse_docnumber}")]
      end

      def parse_docnumber; end

      def create_docid(id)
        Docidentifier.new(type: "PLATEAU", id: id, primary: true)
      end

      def create_formatted_string(content, lang = "ja", script = "Jpan")
        RelatonBib::FormattedString.new(content: content, language: lang, script: script)
      end

      def parse_title
        [create_title(@item["title"], "ja", "Jpan")]
      end

      def create_title(title, lang, script)
        RelatonBib::TypedTitleString.new(type: "main", content: title, language: lang, script: script)
      end

      def parse_abstract; [] end

      def parse_cover
        image_ext = @item["thumbnail"]["mediaItemUrl"].split(".").last
        mimetype = "image/"
        mimetype += image_ext == "jpg" ? "jpeg" : image_ext
        src = "https://www.mlit.go.jp/#{@item["thumbnail"]["mediaItemUrl"]}"
        image = RelatonBib::Image.new(src: src, mimetype: mimetype)
        Cover.new(image)
      end

      def parse_edition; raise "Not implemented" end
      def parse_type; "standard" end
      def parse_doctype; nil end
      def parse_subdoctype; nil end
      def parse_date; [] end
      def parse_link; [] end

      def parse_contributor
        name = [
          { content: "国土交通省", language: "ja", script: "Jpan" },
          {
            content: "Japanese Ministry of Land, Infrastructure, Transport and Tourism",
            language: "en",
            script: "Latn"
          }
        ]
        org = RelatonBib::Organization.new(name: name, abbreviation: "MLIT")
        [RelatonBib::ContributionInfo.new(entity: org, role: [type: "publisher"])]
      end

      def create_date(date, type = "published")
        RelatonBib::BibliographicDate.new(type: type, on: date)
      end

      def create_link(url, type)
        RelatonBib::TypedUri.new(type: type, content: url)
      end

      def parse_filesize; raise "Not implemented" end
      def parse_keyword; [] end
      def parse_structuredidentifier; raise "Not implemented" end
    end
  end
end
