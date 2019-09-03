# frozen_string_literal: true

require 'jekyll'
require 'pry'

module JekyllRPG

  # Add reference to site data
  def self.add_reference(site, doc, reference)
    referent_collection = doc.collection.label
    referent_page = doc.data['slug']

    # Find part of markdown link that represents the collection and item
    referenced_collection = reference[/(?<=\/).*(?=\/)/]
    referenced_page = reference[/(?<=\/)(?:(?!\/).)*?(?=\))/]

    @references = {} if @references.nil?

    @references[referenced_collection] = {} unless @references.key?(referenced_collection)
    @references[referenced_collection][referenced_page] = {} unless @references[referenced_collection].key?(referenced_page)
    @references[referenced_collection][referenced_page][referent_collection] = {} unless @references[referenced_collection][referenced_page].key?(referent_collection)

    @references[referenced_collection][referenced_page][referent_collection][referent_page] = doc.data['name']
  end

  # Bi-directional page links
  Jekyll::Hooks.register :site, :post_read do |site|
    # Don't include references on posts collection
    collection_keys = site.collections.keys - ["posts"]

    # On the site, build a full graph of references between collection pages
    collection_keys.each do |collection|
      site.collections[collection].docs.each do |doc|
        unless doc.data['dm'] && !site.data['dm_mode']
          doc.to_s.scan(/(?<=[^!])\[.*?\]\(\/.*?\/.*?\)/).each do |reference|
            add_reference(site, doc, reference)
          end
        end
      end
    end

    site.data['graph'] = @references


    # For each collection page, add where it is referenced
    collection_keys.each do |collection|
      site.collections[collection].docs.each do |doc|
        # TODO - set the pages as unpublished if in DM mode
        slugs = {}
        collection_keys.each do |add_keys|
          slugs[add_keys] = []
        end
        unless @references[collection].nil? || @references[collection][doc.data['slug']].nil?
          @references[collection][doc.data['slug']].each do |referent|
            referent_collection = referent[0]
            referent[1].each do |x|
              slugs[referent_collection].push("[#{x[1]}](/#{referent_collection}/#{x[0]})")
            end
          end
        end
        doc.data['referenced_by'] = slugs
      end
    end

    # TODO - Conditionally render referents based on site -> collection -> page preference

    # For each reference, if a page does not exist, add it to a not_referenced variable
    site.data['not_referenced'] = []

    @references.each do |collection|
        collection_name = collection[0]
        collection[1].each do |item|
          item_hash = {}
          item_hash['url'] = "#{site.config['url']}/#{collection_name}/#{item[0]}"
          item_hash['collection'] = collection_name
          item_hash['slug'] = item[0]
          item_hash['referenced_by'] = item[1]
          if site.collections[collection_name].nil?
            site.data['not_referenced'].push(item_hash)
          elsif site.collections[collection_name].docs.find { |doc| doc.data['slug'] == item[0] }.nil?
            site.data['not_referenced'].push(item_hash)
          end
        end
    end
  end
end
