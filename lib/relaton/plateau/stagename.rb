module Relaton
  module Plateau
    class Stagename
      # @return [String]
      attr_reader :content

      # @return [String, nil]
      attr_reader :abbreviation

      #
      # Initialize the Stagename object
      #
      # @param [String] content name of the stage
      # @param [String] abbreviation abbreviation of the stage
      #
      def initialize(content:, abbreviation: nil)
        @content = content
        @abbreviation = abbreviation
      end

      def to_xml(builder)
        builder.stagename do |b|
          b.parent[:abbreviation] = abbreviation if abbreviation
          b.text content
        end
      end

      def to_hash
        hash = { content: content }
        hash[:abbreviation] = abbreviation if abbreviation
        hash
      end

      def to_asciibib(prefix = "")
        pref = prefix.empty? ? "stagename" : "#{prefix}.stagename"
        output = "#{pref}.content:: #{content}\n"
        output += "#{pref}.abbreviation:: #{abbreviation}\n" if abbreviation
        output
      end
    end
  end
end
