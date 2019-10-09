# frozen_string_literal: true

module JekyllRPG
  # A markdown link with components extracted from text
  # [name](/collection/slug)
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
