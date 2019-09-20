# frozen_string_literal: true

module JekyllRPG
  # Graph of relationships between CollectionDocuments
  class Graph
    attr_accessor :edges

    def initialize
      @edges = []
    end

    # Get the information for every page the current doc is referenced in
    # And push links to an array that represents the collections of those pages
    def document_references(doc)
      document_hash = {}

      referenced_in(doc).each do |reference|
        document_hash[reference.collection] = [] unless document_hash.key?(reference.collection)
        document_hash[reference.collection].push(reference.markdown_link)
      end

      document_hash.each do |k, v|
        document_hash[k] = v.uniq
      end
      document_hash
    end

    # Based on the graph, returns edges that a specific document is the referent of
    def referenced_in(doc)
      collection = doc.collection.label
      slug = doc.data['slug']
      @edges.select do |edge|
        edge.reference.collection == collection && edge.reference.slug == slug
      end.map { |edge| edge.referent }
    end

    # Based on the graph, returns documents that are referenced, but do not exist yet
    def unwritten
      @edges.reject do |edge|
        edge.reference.written
      end
    end

    def hash
      @edges.map { |edge| edge.hash }
    end
  end
end
