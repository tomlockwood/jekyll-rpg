# frozen_string_literal: true

module JekyllRPG
  # Edge between two documents
  class Edge
    attr_accessor :reference, :referent

    def initialize(referent, reference)
      @referent = referent
      @reference = reference
    end

    def hash
      {
        'reference' => reference.hash,
        'referent' => referent.hash
      }
    end
  end
end
