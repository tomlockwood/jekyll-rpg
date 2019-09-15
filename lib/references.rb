# frozen_string_literal: true

require 'collection_page'

module JekyllRPG
  class References
    attr_accessor :collection_keys, :references, :broken_links, :graph

    def initialize(site)
      @site = site
      @references = {}
      @graph = []
      @broken_links = []
      @collection_keys = @site.collections.keys - ['posts']

      # Parse references from markdown links
      @collection_keys.each do |collection|
        @site.collections[collection].docs.each do |doc|
          if doc.data['dm'] && !@site.data['dm_mode']
            doc.data['published'] = false
          else
            referent = CollectionPage.new(
              doc.data['name'],
              doc.collection.label,
              doc.data['slug'],
              true
            )
            markdown_links(doc).each do |reference|
              @graph.push(edge(referent, reference))
              add_reference(doc, reference)
            end
          end
        end
      end

      # For each collection page, add where it is referenced
      @collection_keys.each do |collection|
        site.collections[collection].docs.each do |doc|
          slugs = {}
          @collection_keys.each do |add_keys|
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
          if doc.data.key?('refs')
            refs_table_required = doc.data['refs']
          elsif site.config['collections'][doc.collection.label].key?('refs')
            refs_table_required = site.config['collections'][doc.collection.label]['refs']
          elsif site.config.key?('refs')
            refs_table_required = site.config['refs']
          end
          if refs_table_required
            doc.content = doc.content + refs_table(doc.data['referenced_by'])
          end
        end
      end

      # Create list of broken links
      @references.each do |collection|
        collection_name = collection[0]
        collection[1].each do |item|
          item_hash = {
            'url' => "#{site.config['url']}/#{collection_name}/#{item[0]}",
            'collection' => collection_name,
            'slug' => item[0],
            'referenced_by' => item[1]
          }
          if page_missing(collection_name, item[0])
            @broken_links.push(item_hash)
          end
        end
      end
    end

    def markdown_links(doc)
      doc.to_s.scan(%r{(?<=[^!])\[.*?\]\(/.*?/.*?\)})
    end

    # returns link text, collection and slug
    # [0](/1/2)
    def link_components(link)
      [link[%r{(?<=\[).*?(?=\])}], link[%r{(?<=/).*(?=/)}], link[%r{(?<=/)(?:(?!/).)*?(?=\))}]]
    end

    def find_page(collection, slug)
      @site.collections[collection].docs.find { |doc| doc.data['slug'] == slug }
    end

    def page_missing(collection, slug)
      @site.collections[collection].nil? || find_page(collection, slug).nil?
    end

    def edge(referent, reference)
      referenced_name, referenced_collection, referenced_slug = link_components(reference)
      if page_missing(referenced_collection, referenced_slug)
        written = false
        name = referenced_name
      else
        written = true
        name = find_page(referenced_collection, referenced_slug).data['name']
      end
      {
        referent: referent,
        reference: CollectionPage.new(
          name,
          referenced_collection,
          referenced_slug,
          written
        )
      }
    end

    def add_reference(doc, reference)
      referent_collection = doc.collection.label
      referent_page = doc.data['slug']

      # Find part of markdown link that represents the collection and item
      referenced_name, referenced_collection, referenced_page = link_components(reference)

      @references[referenced_collection] = {} unless @references.key?(referenced_collection)
      @references[referenced_collection][referenced_page] = {} unless @references[referenced_collection].key?(referenced_page)
      @references[referenced_collection][referenced_page][referent_collection] = {} unless @references[referenced_collection][referenced_page].key?(referent_collection)

      @references[referenced_collection][referenced_page][referent_collection][referent_page] = doc.data['name']
    end

    def refs_table(refs)
      table = <<~TABLE
        # Referenced By:
        <table>
          <thead>
            <tr>
              <th>Collection</th>
              <th>Links</th>
            </tr>
          </thead>
          <tbody>
            #{refs_rows(refs)}
          </tbody>
        </table>
      TABLE
      table
    end

    def refs_rows(refs)
      row = ''
      refs.each do |reference|
        # Don't add the collection name unless there's a reference
        next if reference[1].count == 0

        row += <<~ROW
          <tr>
            <td markdown="span"><b> #{reference[0].capitalize} </b></td>
            <td markdown="span"> #{refs_links(reference)} </td>
          </tr>
        ROW
      end
      row
    end

    def refs_links(reference)
      links = ''
      reference[1].each do |link|
        links += " - #{link} <br>"
      end
      links
    end
  end
end
