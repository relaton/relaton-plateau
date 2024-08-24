module Relaton
  module Plateau
    class Docidentifier < RelatonBib::DocumentIdentifier
      def remove_edition
        @id.sub!(/ \d+\.\d+$/, "")
      end
    end
  end
end
