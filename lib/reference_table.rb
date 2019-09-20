# frozen_string_literal: true

module JekyllRPG
  # Generates Reference Table
  class ReferenceTable
    attr_accessor :html

    def initialize(site, doc)
      @html = ''
      @html = refs_table(doc.data['referenced_by']) if refs_table_required(site, doc)
    end

    # Determines if refs table is required based on document,
    # then collection, then site
    def refs_table_required(site, doc)
      if doc.data.key?('refs')
        doc.data['refs']
      elsif site.config['collections'][doc.collection.label].key?('refs')
        site.config['collections'][doc.collection.label]['refs']
      elsif site.config.key?('refs')
        site.config['refs']
      end
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
