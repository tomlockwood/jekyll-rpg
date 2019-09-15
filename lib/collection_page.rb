# frozen_string_literal: true

module JekyllRPG
  class CollectionPage
    attr_accessor :name, :collection, :slug, :written

    def initialize(name, collection, slug, written)
      @name = name
      @collection = collection
      @slug = slug
      # boolean
      @written = written
    end

    def markdown_link
      "[#{@name}](/#{@collection}/#{@slug})"
    end
  end
end
