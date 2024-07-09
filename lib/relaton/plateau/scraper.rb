require "yaml"
require "json"
require "net/http"
require "uri"
require "date"
require_relative "bibitem"

module Relaton
  module Plateau
    class Scraper
      HANDOOKS_URL = "https://www.mlit.go.jp/plateau/_next/data/1.3.0/libraries/handbooks.json".freeze
      TECHNICAL_REPORTS_URL = "https://www.mlit.go.jp/plateau/_next/data/1.3.0/libraries/technical-reports.json".freeze

      def self.scrape_handbooks
        data = fetch_json_data(HANDOOKS_URL)
        extracted_data = extract_handbooks_data(data)
        save_to_yaml(extracted_data, "handbooks.yaml")
      end

      def self.scrape_technical_reports
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
        request['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:127.0) Gecko/20100101 Firefox/127.0'
        request['Accept'] = '*/*'
        request['Accept-Language'] = 'en-US,en;q=0.5'
        request['Accept-Encoding'] = 'gzip, deflate, br, zstd'
        request['Referer'] = 'https://www.mlit.go.jp/plateau/libraries/'
        request['purpose'] = 'prefetch'
        request['x-nextjs-data'] = '1'
        request['Connection'] = 'keep-alive'

        # Send the request and get the response
        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        # Check if the response is successful
        if response.code.to_i == 200
          body = response.body

          # Handle different content encodings
          if response['Content-Encoding'] == 'gzip'
            body = Zlib::GzipReader.new(StringIO.new(body)).read
          elsif response['Content-Encoding'] == 'deflate'
            body = Zlib::Inflate.inflate(body)
          end

          # Parse the JSON response
          JSON.parse(body)
        else
          puts "Failed to fetch data: #{response.code} #{response.message}"
          {}
        end
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
        json_data['pageProps']['handbooks']['nodes'].map do |entry|
          description_parts = entry['handbook']['description']&.split('<br />') || ["", ""]
          title_en = description_parts[0] ? description_parts[0].strip : ""
          abstract_jp = description_parts[1] ? description_parts[1].strip : ""

          {
            'document_id' => entry['id'],
            'slug' => entry['slug'],
            'title_jp' => entry['handbook']['title'],
            'title_en' => title_en,
            'abstract_jp' => abstract_jp,
            'cover_preview' => entry['handbook']['thumbnail']['mediaItemUrl'],
            'editions' => entry['handbook']['versions'].map do |version|
              {
                'edition_title' => version['title'],
                'publication_date' => version['date'],
                'pdf_link' => version['pdf'],
                'filesize' => version['filesize'],
                'html_link' => version['html']
              }
            end
          }
        end
      rescue StandardError => e
        # Handle any errors during the extraction process
        puts "Error extracting handbooks data: #{e.message}"
        []
      end

      # Extract data for technical reports
      #
      # @param [Hash] json_data The JSON data to extract from
      # @return [Array<Hash>] The extracted technical reports data
      def self.extract_technical_reports_data(json_data)
        puts "Extracting technical reports data..."
        json_data['pageProps']['nodes'].map do |entry|
          {
            'document_id' => entry['id'],
            'slug' => entry['slug'],
            'title' => entry['technicalReport']['title'],
            'abstract' => entry['technicalReport']['subtitle'],
            'publication_date' => entry['date'],
            'cover_preview' => entry['technicalReport']['thumbnail']['mediaItemUrl'],
            'pdf_link' => entry['technicalReport']['pdf'],
            'category' => entry['technicalReportCategories']['nodes'].map { |cat| cat['name'] },
            'tags' => entry['globalTags']['nodes'].map { |tag| tag['name'] }
          }
        end
      rescue StandardError => e
        # Handle any errors during the extraction process
        puts "Error extracting technical reports data: #{e.message}"
        []
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
