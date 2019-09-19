# frozen_string_literal: true

require 'collection_page'
require 'pry'

module JekyllRPG
  # References within Jekyll Collections
  class References
    attr_accessor :collection_keys, :broken_links, :graph

    def initialize(site)
      @site = site
      @graph = []
      @broken_links = []
      @collection_keys = @site.collections.keys - ['posts']

      # Parse references from markdown links
      @collection_keys.each do |collection|
        @site.collections[collection].docs.each do |doc|
          if doc.data['dm'] && !@site.config['dm_mode']
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
            end
          end
        end
      end

      # For each collection page, add where it is referenced
      @collection_keys.each do |collection|
        @site.collections[collection].docs.each do |doc|
          page_refs = {}

          # Get the information for every page the current doc is referenced in
          # And push links to an array that represents the collections of those pages
          referenced_in(collection, doc.data['slug']).each do |reference|
            page_refs[reference.collection] = [] unless page_refs.key?(reference.collection)
            page_refs[reference.collection].push(reference.markdown_link)
          end

          # Make sure links in collections are unique
          page_refs.each do |k, v|
            page_refs[k] = v.uniq
          end

          # Put the reference data on the doc
          doc.data['referenced_by'] = page_refs

          # If the references table option is configured, append the table
          if refs_table_required(doc)
            doc.content = doc.content + refs_table(doc.data['referenced_by'])
          end
        end
      end

      # Create list of broken links
      unwritten_pages.each do |edge|
        @broken_links.push(edge_hash(edge))
      end
    end

    # Find all markdown links in document
    # TODO - fails to find markdown link at very start of doc
    # due to not finding any character that isn't an exclamation mark
    def markdown_links(doc)
      doc.to_s.scan(%r{(?<=[^!])\[.*?\]\(/.*?/.*?\)})
    end

    # returns link text, collection and slug
    # [0](/1/2) - as a [0, 1, 2]
    def link_components(link)
      [link[/(?<=\[).*?(?=\])/], link[%r{(?<=/).*(?=/)}], link[%r{(?<=/)(?:(?!/).)*?(?=\))}]]
    end

    # Find a document based on its collection and slug
    def find_page(collection, slug)
      @site.collections[collection].docs.find { |doc| doc.data['slug'] == slug }
    end

    # Returns true if document cannot be found in collection
    def page_missing(collection, slug)
      @site.collections[collection].nil? || find_page(collection, slug).nil?
    end

    # Returns a hash of two CollectionPages representing a graph edge
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
        'referent' => referent,
        'reference' => CollectionPage.new(
          name,
          referenced_collection,
          referenced_slug,
          written
        )
      }
    end

    # Based on the graph, returns edges that a specific document is the referent of
    def referenced_in(collection, slug)
      @graph.select do |edge|
        edge['reference'].collection == collection && edge['reference'].slug == slug
      end.map { |edge| edge['referent'] }
    end

    # Based on the graph, returns documents that are referenced, but do not exist yet
    def unwritten_pages
      @graph.reject do |edge|
        edge['reference'].written
      end
    end

    # Determines if refs table is required based on document,
    # then collection, then site
    def refs_table_required(doc)
      if doc.data.key?('refs')
        doc.data['refs']
      elsif @site.config['collections'][doc.collection.label].key?('refs')
        @site.config['collections'][doc.collection.label]['refs']
      elsif @site.config.key?('refs')
        @site.config['refs']
      end
    end

    # Returns an easily accessible hash representing an edge for Jekyll purposes
    def edge_hash(edge)
      {
        'reference_name' => edge['reference'].name,
        'reference_collection' => edge['reference'].collection,
        'reference_slug' => edge['reference'].slug,
        'reference_link' => edge['reference'].markdown_link,
        'referent_name' => edge['referent'].name,
        'referent_collection' => edge['referent'].collection,
        'referent_slug' => edge['referent'].slug,
        'referent_link' => edge['referent'].markdown_link
      }
    end

    # Returns a graph made up of hashed edges
    def hashed_graph
      @graph.map { |edge| edge_hash(edge) }
    end

    # The following three functions return a HTML table
    # That for a specific document shows the documents that
    # reference it

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
