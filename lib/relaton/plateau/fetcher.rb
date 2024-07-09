require "yaml"
require "json"
require "net/http"
require "uri"
require "date"
require_relative "bibitem"

module Relaton
  module Plateau
    class Fetcher
      HANDBOOKS_URL = "https://www.mlit.go.jp/plateau/_next/data/1.3.0/libraries/handbooks.json".freeze
      TECHNICAL_REPORTS_URL = "https://www.mlit.go.jp/plateau/_next/data/1.3.0/libraries/technical-reports.json".freeze

      def self.fetch_handbooks
        data = fetch_json_data(HANDBOOKS_URL)
        extracted_data = extract_handbooks_data(data)
        save_to_yaml(extracted_data, "handbooks.yaml")
      end

      def self.fetch_technical_reports
        data = fetch_json_data(TECHNICAL_REPORTS_URL)
        extracted_data = extract_technical_reports_data(data)
        save_to_yaml(extracted_data, "technical_reports.yaml")
      end

      # Fetch JSON data from a URL with custom headers
      #
      # @param [String] url The URL to fetch JSON data from
      # @return [Hash] The parsed JSON data
      def self.fetch_json_data(url)
        uri = URI(url)

        # Create a GET request with custom headers to mimic a browser
        request = Net::HTTP::Get.new(uri)
        request["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:127.0) Gecko/20100101 Firefox/127.0"
        request["Accept"] = "*/*"
        request["Accept-Language"] = "en-US,en;q=0.5"
        request["Accept-Encoding"] = "gzip, deflate, br, zstd"
        request["Referer"] = "https://www.mlit.go.jp/plateau/libraries/"
        request["purpose"] = "prefetch"
        request["x-nextjs-data"] = "1"
        request["Connection"] = "keep-alive"

        # Send the request and get the response
        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        # Check if the response is successful
        unless response.code.to_i == 200
          puts "Failed to fetch data: #{response.code} #{response.message}"
          {}
        end

        body = response.body

        # Handle different content encodings
        if response["Content-Encoding"] == "gzip"
          body = Zlib::GzipReader.new(StringIO.new(body)).read
        elsif response["Content-Encoding"] == "deflate"
          body = Zlib::Inflate.inflate(body)
        end

        # Parse the JSON response
        JSON.parse(body)
      rescue StandardError => e
        # Handle any errors during the fetching process
        puts "Error fetching JSON data from #{url}: #{e.message}"
        {}
      end

      # Extract data for handbooks
      #
      # @param [Hash] json_data The JSON data to extract from
      # @return [Array<Hash>] The extracted handbooks data
      def self.extract_handbooks_data(json_data)
        puts "Extracting handbooks data..."
        json_data["pageProps"]["handbooks"]["nodes"].map do |entry|
          handbook = entry["handbook"]
          versions = handbook["versions"]

          description_parts = handbook["description"]&.split("<br />") || ["", ""]
          title_en = description_parts[0] ? description_parts[0].strip : ""
          abstract_jp = description_parts[1] ? description_parts[1].strip : ""

          versions.map do |version|
            ::Relaton::Plateau::BibItem.new(
              pubid: "PLATEAU Handbook ##{entry["slug"]}",
              title_jp: handbook["title"],
              title_en: title_en,
              abstract_jp: abstract_jp,
              cover: "https://www.mlit.go.jp/#{handbook["thumbnail"]["mediaItemUrl"]}",
              type: "handbook",
              publication_date: Date.parse(version["date"].gsub(".", "-")),
              url_pdf: version["pdf"],
              url_html: version["html"],
              filesize: version["filesize"].to_i,
              edition_number: version["title"].match(/\d\.\d/)[0],
              edition_text: version["title"],
              # tags: [],
            )
          end
        end.flatten
      end

      # Extract data for technical reports
      #
      # @param [Hash] json_data The JSON data to extract from
      # @return [Array<Hash>] The extracted technical reports data
      def self.extract_technical_reports_data(json_data)
        puts "Extracting technical reports data..."
        json_data["pageProps"]["nodes"].map do |entry|
          technical_report = entry["technicalReport"]

          ::Relaton::Plateau::BibItem.new(
            title_jp: technical_report["title"],
            abstract_jp: technical_report["subtitle"],
            cover: "https://www.mlit.go.jp/#{technical_report["thumbnail"]["mediaItemUrl"]}",
            pubid: "PLATEAU Tech Report ##{entry["slug"]}",
            type: "technical-report",
            subtype: entry["technicalReportCategories"]["nodes"].map { |cat| cat["name"] },
            publication_date: Date.parse(entry["date"]),
            url_pdf: technical_report["pdf"],
            filesize: technical_report["filesize"].to_i,
            edition_number: "1.0",
            edition_text: "1.0",
            tags: entry["globalTags"]["nodes"].map { |tag| tag["name"] },
          )
        end
      end

      def self.save_to_yaml(data, filename)
        File.open(filename, "w") do |file|
          file.write(data.to_yaml)
        end
        puts "Data saved to #{filename}."
      end
    end
  end
end
