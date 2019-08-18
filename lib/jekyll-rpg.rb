# frozen_string_literal: true

require 'jekyll'
require 'pry'

module JekyllRPG

  # Add reference to site data
  def self.add_reference(site, doc, reference)
    referent_collection = doc.collection.label
    referent_page = doc.data['slug']
    referenced_collection = reference[/(?<=\/).*(?=\/)/]
    referenced_page = reference[/(?<=\/)(?:(?!\/).)*?(?=\))/]
    site.data['references'] = {} unless site.data.key?('references')

    site.data['references'][referenced_collection] = {} unless site.data['references'].key?(referenced_collection)
    site.data['references'][referenced_collection][referenced_page] = {} unless site.data['references'][referenced_collection].key?(referenced_page)
    site.data['references'][referenced_collection][referenced_page][referent_collection] = [] unless site.data['references'][referenced_collection][referenced_page].key?(referent_collection)

    site.data['references'][referenced_collection][referenced_page][referent_collection].append({slug: referent_page, name: doc.data['name']})
  end

  # Determine links between sites
  Jekyll::Hooks.register :site, :post_read do |site|
    collection_keys = site.collections.keys - ["posts"]
    collection_keys.each do |collection|
      site.collections[collection].docs.each do |doc|
        doc.to_s.scan(/(?<=[^!])\[.*\]\(\/.*\/.*\)/).each do |reference|
          add_reference(site, doc, reference)
        end
      end
    end

    collection_keys.each do |collection|
      site.collections[collection].docs.each do |doc|
        doc.data['referenced_by'] = site.data['references'][collection][doc.data['slug']]
      end
    end
  end
end
