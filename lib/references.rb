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
          page_refs = {}

          # Get the information for every page the current doc is referenced in
          # And push links to an array that represents the collections of those pages
          referenced_in(collection, doc.data['slug'] ).each do |reference|
            page_refs[reference.collection] = [] unless page_refs.key?(reference.collection)
            page_refs[reference.collection].push(reference.markdown_link)
          end

          # Make sure links in collections are unique
          page_refs.each do |k,v|
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

      #print broken_links

      # Create list of broken links
      unwritten_pages.each do |edge|
        @broken_links.push({
          'reference_name' => edge['reference'].name,
          'reference_collection' => edge['reference'].collection,
          'reference_slug' => edge['reference'].slug,
          'reference_link' => edge['reference'].markdown_link,
          'referent_name' => edge['referent'].name,
          'referent_collection' => edge['referent'].collection,
          'referent_slug' => edge['referent'].slug,
          'referent_link' => edge['referent'].markdown_link,
        })
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
        'referent' => referent,
        'reference' => CollectionPage.new(
          name,
          referenced_collection,
          referenced_slug,
          written
        )
      }
    end

    def referenced_in(collection, slug)
      @graph.select {
        |edge| edge['reference'].collection == collection && edge['reference'].slug == slug
      }.map { |edge| edge['referent'] }
    end

    def unwritten_pages
      @graph.select {
        |edge| !edge['reference'].written
      }
    end

    def refs_table_required(doc)
      if doc.data.key?('refs')
        doc.data['refs']
      elsif @site.config['collections'][doc.collection.label].key?('refs')
        @site.config['collections'][doc.collection.label]['refs']
      elsif @site.config.key?('refs')
        @site.config['refs']
      end
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
