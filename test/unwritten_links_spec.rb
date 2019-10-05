# frozen_string_literal: true

require_relative 'spec_helper'

# End-to-end tests via Jekyll
describe 'Unwritten links' do
  let(:site)    { create :site, renders: true }
  let(:bethany) { doc_named(site, 'Bethany').content }
  let(:bungus)  { doc_named(site, 'Bungus').content }

  context 'with defaults' do
    it 'strikes through the broken links' do
      expect(bethany).to include(
        '<del><a href="/faults/bethany">All bethany’s faults</a></del>'
      )
      expect(bethany).to include(
        '<del><a href="/history/rise_of_bethany">rise</a></del>'
      )
    end

    it 'strikes through links to dm content' do
      expect(bungus).to include(
        '<del><a href="/gods/nega_bruce">Nega Bruce</a></del>'
      )
    end
  end

  context 'with dm_mode enabled' do
    let(:site) { create :site, dm_mode: true, renders: true }

    it 'strikes through links to dm content' do
      expect(bungus).to include(
        '<a href="/gods/nega_bruce">Nega Bruce</a>'
      )
      expect(bungus).not_to include(
        '<del>'
      )
    end
  end
end
