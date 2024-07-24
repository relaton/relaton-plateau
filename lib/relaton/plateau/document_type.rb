module Relaton
  module Plateau
    class DocumentType < RelatonBib::DocumentType
      DOCTYPES = %w[handbook technical-report annex].freeze

      def initialize(type:, abbreviation: nil)
        check_type type
        super
      end

      def check_type(type)
        return if DOCTYPES.include? type

        Util.warn "invalid doctype: `#{type}`"
      end
    end
  end
end
