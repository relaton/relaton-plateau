require_relative "cover"
require_relative "stagename"

module Relaton
  module Plateau
    class BibItem < RelatonBib::BibliographicItem
      # @return [Relaton::Plateau::Cover]
      attr_reader :cover

      # @return [Relaton::Plateau::Stagename]
      attr_reader :stagename

      # @return [Integer]
      attr_reader :filesize

      def initialize(**args)
        @cover = args.delete(:cover)
        @filesize = args.delete(:filesize)
        @stagename = args.delete(:stagename)
        super(**args)
      end

      #
      # Fetch flavor schema version
      #
      # @return [String] schema version
      #
      def ext_schema
        @ext_schema ||= schema_versions["relaton-model-plateau"]
      end

      # @param opts [Hash]
      # @option opts [Nokogiri::XML::Builder] :builder XML builder
      # @option opts [Boolean] bibdata
      # @option opts [Symbol, nil] :date_format (:short), :full
      # @option opts [String] :lang language
      def to_xml(**opts)
        super do |builder|
          if opts[:bibdata] && has_ext_data?
            ext = builder.ext do |b|
              doctype&.to_xml b
              b.subdoctype subdoctype if subdoctype
              editorialgroup&.to_xml b
              ics.each { |i| b.ics i }
              structuredidentifier&.to_xml b
              stagename&.to_xml b
              cover.to_xml b
              b.filesize filesize
            end
            ext["schema-version"] = ext_schema if !opts[:embedded] && respond_to?(:ext_schema) && ext_schema
          end
        end
      end

      def to_hash
        hash = super
        return hash unless has_ext_data?

        hash["ext"] ||= {}
        hash["ext"]["stagename"] = stagename.to_hash if stagename
        hash["ext"]["cover"] = cover.to_hash if cover
        hash["ext"]["filesize"] = filesize if filesize
        hash
      end

      def to_asciibib(prefix = "")
        pref = prefix.empty? ? "" : "#{prefix}."
        output = super
        output += stagename.to_asciibib prefix if stagename
        output += cover.to_asciibib prefix if cover
        output += "#{pref}filesize:: #{filesize}\n" if filesize
        output
      end

      private

      def has_ext_data?
        doctype || subdoctype || editorialgroup || ics&.any? || structuredidentifier || stagename || cover || filesize
      end
    end
  end
end
