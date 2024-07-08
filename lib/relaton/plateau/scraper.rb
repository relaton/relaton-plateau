require "nokogiri"
require "yaml"
require "json"
require "net/http"
require "uri"
require_relative "bibitem"

module Relaton
  module Plateau
    class Scraper
      HANDOOKS_URL = "https://www.mlit.go.jp/plateau/libraries/handbooks/".freeze
      TECHNICAL_REPORTS_URL = "https://www.mlit.go.jp/plateau/_next/data/1.3.0/libraries/technical-reports.json".freeze

      def self.scrape_handbooks
        data = fetch_handbooks
        save_to_yaml(data, "handbooks.yaml")
      end

      def self.scrape_technical_reports
        data = fetch_technical_reports
        save_to_yaml(data, "technical_reports.yaml")
      end

      def self.fetch_handbooks
        response = fetch_html(HANDOOKS_URL)
        return [] unless response

        doc = Nokogiri::HTML(response)
        (0..12).map do |i|
          id = format("%02d", i)
          div = doc.at_css("##{id}")
          next unless div

          ::Relaton::Plateau::BibItem.new(
            slug_value: "##{id}",
            book_title: div.at_css(".handbooks_list_title__HZ48a")&.text&.strip,
            book_description: div.at_css(".handbooks_list_description__YvC2S p")&.text&.strip,
            download_value: div.at_css(".handbooks_list_select_btn__qKfQJ")&.text&.strip,
            pdf_link: div.at_css(".handbooks_list_bottom_buttons__q5jEg a")&.[]("href"),
          )
        end.compact
      end

      def self.fetch_technical_reports
        response = fetch_json(TECHNICAL_REPORTS_URL)
        return [] unless response

        nodes = response["pageProps"]["nodes"]
        nodes.map do |node|
          ::Relaton::Plateau::BibItem.new(
            slug_value: node["id"],
            publication_date: node["date"],
            book_title: node["technicalReport"]["title"],
            book_subtitle: node["technicalReport"]["subtitle"],
            pdf_link: node["technicalReport"]["pdf"],
            download_value: node["technicalReport"]["filesize"],
            tags: node["globalTags"]["nodes"].map { |tag| tag["name"] },
          )
        end
      end

      def self.fetch_html(url)
        uri = URI.parse(url)
        response = Net::HTTP.get_response(uri)
        return response.body if response.is_a?(Net::HTTPSuccess)

        puts "Failed to retrieve data. HTTP Status Code: #{response.code}"
        nil
      end

      def self.fetch_json(url)
        uri = URI.parse(url)
        response = Net::HTTP.get_response(uri)
        return JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)

        puts "Failed to fetch JSON data: #{response.code}"
        nil
      end

      def self.save_to_yaml(data, filename)
        File.open(filename, "w") do |file|
          file.write(data.map(&:to_hash).to_yaml)
        end
        puts "Data saved to #{filename}."
      end
    end
  end
end
