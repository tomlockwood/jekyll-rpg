# frozen_string_literal: true

require_relative 'spec_helper'

# End-to-end tests via Jekyll
describe 'Make Jekyll-RPG References' do
  let(:site)    { create :site }

  context 'with defaults' do
    it 'makes a graph with nodes representing links between pages' do
      expect(
        site.jekyll.data['graph'][0]['reference']['name']
      ).to eq('Slaying of Bethany')
    end

    it 'puts the references on documents' do
      expect(
        doc_named(site, 'Bethany').data['referenced_by']['history']
      ).to eq ['[Slaying of Bethany](/history/slaying_of_bethany)']
    end

    it 'does not show references from DM material' do
      expect(
        doc_named(site, 'Bethany').data['referenced_by']['gods']
      ).to eq nil
    end

    it 'does not publish DM material' do
      expect(doc_named(site, 'Nega Bruce').data['published']).to eq false
    end

    it 'generates a list of broken links' do
      expect(
        site.jekyll.data['broken_links'].find do |link|
          link['reference']['link'] == '[Bruce](/gods/bruce)'
        end['reference']['slug']
      ).to eq('bruce')
    end

    it 'does not include pages that exist as broken links' do
      expect(
        site.jekyll.data['broken_links'].find do |link|
          link['reference']['link'] == '[Bethany](/gods/bethany)'
        end
      ).to be nil
    end
  end

  context 'with refs at a site level' do
    let(:site)    { create :site, refs: true }
    let(:bethany) { doc_named(site, 'Bethany').content }

    it 'puts a table with references on the documents' do
      expect(bethany).to include('<table>')
    end

    it 'puts a link to the referencing document on the document' do
      expect(bethany).to include(
        '[Slaying of Bethany](/history/slaying_of_bethany)'
      )
    end

    it 'does not include a collection row for a collection that has no refs' do
      expect(bethany).not_to include('Gods')
    end
  end

  context 'with dm_mode set to true' do
    let(:site)  { create :site, dm_mode: true }

    it 'does shows references from DM material' do
      expect(
        doc_named(site, 'Bethany').data['referenced_by']['gods']
      ).to eq ['[Nega Bruce](/gods/nega_bruce)']
    end

    it 'does not block publishing dm material' do
      expect(doc_named(site, 'Nega Bruce').data['published']).not_to eq false
    end
  end
end
