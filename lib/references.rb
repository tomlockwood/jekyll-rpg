# frozen_string_literal: true

require 'collection_document'
require 'edge'
require 'graph'
require 'markdown_link'
require 'reference_table'

module JekyllRPG
  # References within Jekyll Collections
  class References
    attr_accessor :collection_keys, :broken_links, :graph

    def initialize(site)
      @site = site
      @dm_mode = @site.config['dm_mode']
      @graph = Graph.new
      @broken_links = []
      @collection_keys = @site.collections.keys - ['posts']

      reference_pass
      referent_pass

      # Create list of broken links
      @graph.unwritten.each do |edge|
        @broken_links.push(edge.hash)
      end
    end

    # Generating data on how documents reference other documents
    def reference_pass
      # Parse references from markdown links
      collection_documents.each do |doc|
        # Do not publish or reference a page if the site is not in DM Mode
        # And the page is marked as for dms
        if doc.data['dm'] && !@dm_mode
          doc.data['published'] = false
        else
          unwritten_links = []
          referent = CollectionDocument.new.extract_doc(doc)
          markdown_links(doc).each do |link|
            md_link = MarkdownLink.new(link)
            reference = CollectionDocument.new.extract_markdown(@site, md_link)
            unwritten_links << reference.markdown_link unless reference.written
            @graph.edges.push(Edge.new(referent, reference))
          end

          # Unwritten links are struck through
          unwritten_links.uniq.each do |link|
            doc.content = doc.content.sub! link, "~~#{link}~~"
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
        table = ReferenceTable.new(@site, doc).html
        doc.content = doc.content + table
      end
    end

    def collection_documents
      @collection_keys.flat_map do |collection|
        @site.collections[collection].docs
      end
    end

    # Find all markdown links in document
    # TODO - fails to find markdown link at very start of doc
    # due to not finding any character that isn't an exclamation mark
    def markdown_links(doc)
      doc.to_s.scan(%r{(?<=[^!])\[.*?\]\(/.*?/.*?\)})
    end
  end
end
