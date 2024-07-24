require "net/http"
require "uri"
require "relaton/index"
require "relaton_bib"
require_relative "plateau/version"
require_relative "plateau/util"
require_relative "plateau/document_type"
require_relative "plateau/bibitem"
require_relative "plateau/bibliography"
require_relative "plateau/xml_parser"
require_relative "plateau/hash_converter"
require_relative "plateau/fetcher"

module Relaton
  module Plateau
    class Error < StandardError; end

    # Your code goes here...
  end
end
