require "nokogiri"
require "yaml"
require "json"
require "net/http"
require "uri"
require "date"
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
        json = doc.at_css("#__NEXT_DATA__")
        data = JSON.parse(json)
        items = data["props"]["pageProps"]["handbooks"]["nodes"]

        items.map do |node|
          handbook = node["handbook"]
          versions = handbook["versions"]

          versions.map do |version|
            ::Relaton::Plateau::BibItem.new(
              title: handbook["title"],
              abstract: handbook["subtitle"],
              cover: "https://www.mlit.go.jp/#{handbook["thumbnail"]["mediaItemUrl"]}",
              pubid: "PLATEAU Handbook ##{node["slug"]}",
              type: "handbook",
              publication_date: Date.parse(version["date"].gsub(".", "-")),
              pdf_link: version["pdf"],
              filesize: version["filesize"].to_i,
              edition_number: version["title"].match(/\d\.\d/)[0],
              edition_text: version["title"],
              tags: [],
            )
          end
        end.flatten
      end

      def self.fetch_technical_reports
        response = fetch_json(TECHNICAL_REPORTS_URL)
        return [] unless response

        nodes = response["pageProps"]["nodes"]
        nodes.map do |node|
          technical_report = node["technicalReport"]

          ::Relaton::Plateau::BibItem.new(
            title: technical_report["title"],
            abstract: technical_report["subtitle"],
            cover: "https://www.mlit.go.jp/#{technical_report["thumbnail"]["mediaItemUrl"]}",
            pubid: "PLATEAU Tech Report ##{node["slug"]}",
            type: "technical-report",
            subtype: node["technicalReportCategories"]["nodes"].first["name"],
            publication_date: Date.parse(node["date"]),
            pdf_link: technical_report["pdf"],
            filesize: technical_report["filesize"].to_i,
            edition_number: "1",
            edition_text: nil,
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
