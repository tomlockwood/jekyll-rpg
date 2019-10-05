# frozen_string_literal: true

module JekyllRPG
  # Represents a document that may be in a Jekyll collection
  class MarkdownLink
    def initialize(link)
      @link = link
    end

    def name
      @link[/(?<=\[).*?(?=\])/]
    end

    def slug
      @link[%r{(?<=/)(?:(?!/).)*?(?=\))}]
    end

    def collection
      @link[%r{(?<=/).*(?=/)}]
    end
  end
end