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
      @site = site
      @collection = link.collection
      @slug = link.slug
      @written = viewable
      @name = @written ? find_document.data['name'] : link.name
      self
    end

    # Checks whether document exists in a site
    def document_exists
      !@site.collections[@collection].nil? && !find_document.nil?
    end

    # Find a document based on its collection and slug
    def find_document
      @site.collections[@collection].docs.find { |doc| doc.data['slug'] == @slug }
    end

    # Figure out if the document is clickable or not
    def clickable
      @written && viewable
    end

    def viewable
      return unless document_exists

      @site.config['dm_mode'] || !find_document.data['dm']
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
