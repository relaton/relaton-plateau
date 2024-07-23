require "json"
require "net/http"
require "uri"
require "date"
require_relative "parser"
require_relative "handbook_parser"
require_relative "technical_report_parser"

module Relaton
  module Plateau
    # Fetcher class to fetch data from the Plateau website
    class Fetcher
      HANDBOOKS_URL = "https://www.mlit.go.jp/plateau/_next/data/1.3.0/libraries/handbooks.json".freeze
      TECHNICAL_REPORTS_URL = "https://www.mlit.go.jp/plateau/_next/data/1.3.0/libraries/technical-reports.json".freeze

      def initialize(output, format)
        @output = output
        @format = format
        @ext = format.sub(/^bib/, "")
        @files = []
      end

      def index
        @index ||= Relaton::Index.find_or_create :plateau, file: "index-v1.yaml"
      end

      def self.fetch(source, output: "data", format: "yaml")
        t1 = Time.now
        puts "Started at: #{t1}"
        FileUtils.mkdir_p output

        if source == "plateau-handbooks"
          new(output, format).extract_handbooks_data
        elsif source == "plateau-technical-reports"
          new(output, format).extract_technical_reports_data
        else
          puts "Invalid source: #{source}"
        end

        t2 = Time.now
        puts "Stopped at: #{t2}"
        puts "Done in: #{(t2 - t1).round} sec."
      end

      # def fetch_handbooks
      #   data = fetch_json_data(HANDBOOKS_URL)
      #   extracted_data = extract_handbooks_data(data)
      #   save_to_yaml(extracted_data, "handbooks.yaml")
      # end

      # def fetch_technical_reports
      #   data = fetch_json_data(TECHNICAL_REPORTS_URL)
      #   extracted_data = extract_technical_reports_data(data)
      #   save_to_yaml(extracted_data, "technical_reports.yaml")
      # end

      # Create a GET request with custom headers to mimic a browser
      def create_request(uri)
        request = Net::HTTP::Get.new(uri)
        request["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:127.0) Gecko/20100101 Firefox/127.0"
        request["Accept"] = "*/*"
        request["Accept-Language"] = "en-US,en;q=0.5"
        request["Accept-Encoding"] = "gzip, deflate, br, zstd"
        request["Referer"] = "https://www.mlit.go.jp/plateau/libraries/"
        request["purpose"] = "prefetch"
        request["x-nextjs-data"] = "1"
        request["Connection"] = "keep-alive"
        request
      end

      # Handle different content encodings
      def hadle_response(response)
        if response["Content-Encoding"] == "gzip"
          Zlib::GzipReader.new(StringIO.new(response.body)).read
        elsif response["Content-Encoding"] == "deflate"
          Zlib::Inflate.inflate(response.body)
        else
          response.body
        end
      end

      # Fetch JSON data from a URL with custom headers
      #
      # @param [String] url The URL to fetch JSON data from
      # @return [Hash] The parsed JSON data
      def fetch_json_data(url)
        uri = URI(url)

        request = create_request(uri)

        # Send the request and get the response
        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        # Check if the response is successful
        unless response.code.to_i == 200
          Util.warn "Failed to fetch data: #{response.code} #{response.message}"
          return {}
        end

        body = hadle_response(response)

        # Parse the JSON response
        JSON.parse(body)
      rescue StandardError => e
        # Handle any errors during the fetching process
        Util.error "Error fetching JSON data from #{url}: #{e.message}"
        {}
      end

      #
      # Extract data for handbooks
      #
      def extract_handbooks_data
        data = fetch_json_data(HANDBOOKS_URL)
        # puts "Extracting handbooks data..."
        data["pageProps"]["handbooks"]["nodes"].each do |entry|
          handbook = entry["handbook"]
          versions = handbook["versions"]

          description_parts = handbook["description"]&.split("<br />") || ["", ""]
          title_en = description_parts[0].strip if description_parts[0]
          abstract = description_parts[1].strip if description_parts[1]

          doctype = entry["slug"].match("-") ?  "annex" : "handbook"

          versions.each do |version|
            item = HandbookParser.new(
              version: version, entry: entry, title_en: title_en, abstract: abstract, doctype: doctype
            ).parse
            save_document(item)

            # ::Relaton::Plateau::BibItem.new(
            #   pubid: "PLATEAU Handbook ##{entry["slug"]}",
            #   title_jp: handbook["title"],
            #   title_en: title_en,
            #   abstract_jp: abstract_jp,
            #   cover: "https://www.mlit.go.jp/#{handbook["thumbnail"]["mediaItemUrl"]}",
            #   type: document_type,
            #   publication_date: Date.parse(version["date"].gsub(".", "-")),
            #   url_pdf: version["pdf"],
            #   url_html: version["html"],
            #   filesize: version["filesize"].to_i,
            #   edition_number: version["title"].match(/\d\.\d/)[0],
            #   edition_text: version["title"],
            #   # tags: [],
            # )
          end
        end
        index.save
      end

      #
      # Extract data for technical reports
      #
      def extract_technical_reports_data
        data = fetch_json_data(TECHNICAL_REPORTS_URL)
        puts "Extracting technical reports data..."
        data["pageProps"]["nodes"].map do |entry|
          save_document(TechnicalReportParser.new(entry).parse)

          # technical_report = entry["technicalReport"]

          # ::Relaton::Plateau::BibItem.new(
          #   title_jp: technical_report["title"],
          #   abstract_jp: technical_report["subtitle"],
          #   cover: "https://www.mlit.go.jp/#{technical_report["thumbnail"]["mediaItemUrl"]}",
          #   pubid: "PLATEAU Tech Report ##{entry["slug"]}",
          #   type: "technical-report",
          #   subtype: entry["technicalReportCategories"]["nodes"].map { |cat| cat["name"] },
          #   publication_date: Date.parse(entry["date"]),
          #   url_pdf: technical_report["pdf"],
          #   filesize: technical_report["filesize"].to_i,
          #   edition_number: "1.0",
          #   edition_text: "1.0",
          #   tags: entry["globalTags"]["nodes"].map { |tag| tag["name"] },
          # )

        end
        index.save
      end

      # def self.save_to_yaml(data, filename)
      #   File.open(filename, "w") do |file|
      #     file.write(data.to_yaml)
      #   end
      #   puts "Data saved to #{filename}."
      # end

      def save_document(item)
        id = item.docidentifier.first.id
        file = file_name id
        if @files.include?(file)
          Util.warn "File #{file} already exists, skipping.", key: id
        else
          File.write(file, serialize(item))
          @files << file
          index.add_or_update id, file
        end
      end

      def file_name(id)
        name = id.gsub(/\s+/, "_").gsub(/\W+/, "").downcase
        if id.match?(/民間活用編/)
          name += "_private"
        elsif id.match?(/公共活用編/)
          name += "_public"
        end
        File.join(@output, "#{name}.#{@ext}")
      end

      def serialize(item)
        case @format
        when "yaml" then item.to_hash.to_yaml
        when "xml" then item.to_xml bibdata: true
        else item.send("to_#{@format}")
        end
      end
    end
  end
end
