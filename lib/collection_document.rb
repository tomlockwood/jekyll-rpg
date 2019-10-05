# frozen_string_literal: true

module JekyllRPG
  # Represents a document that may be in a Jekyll collection,
  # extracted from either a document itself, or a markdown
  # link.
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
    def extract_markdown(site, link)
      @collection = link.collection
      @slug = link.slug
      @written = document_exists(site)
      @name = @written ? find_document(site).data['name'] : link.name
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

    def hash
      {
        'name' => @name,
        'collection' => @collection,
        'slug' => @slug,
        'link' => markdown_link
      }
    end
  end
end
