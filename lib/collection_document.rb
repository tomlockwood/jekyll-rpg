# frozen_string_literal: true

require 'pry'

module JekyllRPG
  # Represents a document that may be in a Jekyll collection
  class CollectionDocument
    attr_accessor :name, :collection, :slug, :written

    def extract_doc(doc)
      @name = doc.data['name']
      @collection = doc.collection.label
      @slug = doc.data['slug']
      @written = true
      self
    end

    # extracts link text, collection and slug
    # [@name](/@collection/@slug)
    def extract_markdown(site, link)
      @collection = link[%r{(?<=/).*(?=/)}]
      @slug = link[%r{(?<=/)(?:(?!/).)*?(?=\))}]
      @written = document_exists(site)
      @name = @written ? find_document(site).data['name'] : link[/(?<=\[).*?(?=\])/]
      self
    end

    # Checks whether document exists in a site
    def document_exists(site)
      !site.collections[@collection].nil? && !find_document(site).nil?
    end

    # Find a document based on its collection and slug
    def find_document(site)
      site.collections[@collection].docs.find { |doc| doc.data['slug'] == @slug }
    end

    def markdown_link
      "[#{@name}](/#{@collection}/#{@slug})"
    end
  end
end
