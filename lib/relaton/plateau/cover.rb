module Relaton
  module Plateau
    class Cover
      # @return [RelatonBib::Image]
      attr_reader :image

      #
      # Initialize the Cover object
      #
      # @param [RelatonBib::Image] image image object
      #
      def initialize(image)
        @image = image
      end

      def to_xml(builder)
        builder.cover do |b|
          image.to_xml b
        end
      end

      def to_hash
        image.to_hash
      end

      def to_asciibib(prefix = "")
        pref = prefix.empty? ? "cover" : "#{prefix}.cover"
        image.to_asciibib pref
      end
    end
  end
end
