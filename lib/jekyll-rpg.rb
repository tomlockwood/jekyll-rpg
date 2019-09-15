# frozen_string_literal: true

require 'jekyll'
require_relative 'references'

module JekyllRPG
  # Bi-directional page links
  Jekyll::Hooks.register :site, :post_read do |site|
    ref = References.new(site)

    site.data['graph'] = ref.graph

    site.data['broken_links'] = ref.broken_links
  end
end
