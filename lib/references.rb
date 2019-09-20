# frozen_string_literal: true

require 'collection_document'
require 'graph'
require 'pry'

module JekyllRPG
  # References within Jekyll Collections
  class References
    attr_accessor :collection_keys, :broken_links, :graph

    def initialize(site)
      @site = site
      @graph = Graph.new
      @broken_links = []
      @collection_keys = @site.collections.keys - ['posts']

      reference_pass
      referent_pass

      # Create list of broken links
      @graph.unwritten.each do |edge|
        @broken_links.push(edge_hash(edge))
      end
    end

    # Generating data on how documents reference other documents
    def reference_pass
      # Parse references from markdown links
      collection_documents.each do |doc|
        # Do not publish or reference a page if the site is not in DM Mode
        # And the page is marked as for dms
        if doc.data['dm'] && !@site.config['dm_mode']
          doc.data['published'] = false
        else
          referent = CollectionDocument.new.extract_doc(doc)
          markdown_links(doc).each do |link|
            reference = CollectionDocument.new.extract_markdown(@site, link)
            @graph.edges.push('referent' => referent, 'reference' => reference)
          end
        end
      end
    end

    # Generating data on how documents are referenced to
    def referent_pass
      # For each collection page, add where it is referenced
      collection_documents.each do |doc|
        # Put the reference data on the doc
        doc.data['referenced_by'] = @graph.document_references(doc)

        # If the references table option is configured, append the table
        if refs_table_required(doc)
          doc.content = doc.content + refs_table(doc.data['referenced_by'])
        end
      end
    end

    def collection_documents
      @collection_keys.flat_map { |collection| @site.collections[collection].docs }
    end

    # Find all markdown links in document
    # TODO - fails to find markdown link at very start of doc
    # due to not finding any character that isn't an exclamation mark
    def markdown_links(doc)
      doc.to_s.scan(%r{(?<=[^!])\[.*?\]\(/.*?/.*?\)})
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
      @graph.edges.map { |edge| edge_hash(edge) }
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
