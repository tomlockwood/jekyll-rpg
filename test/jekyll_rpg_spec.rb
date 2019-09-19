# frozen_string_literal: true

require 'jekyll'
require_relative 'spec_helper'

describe 'Make Jekyll-RPG site' do
  let(:dm_mode) { false }
  let(:refs)    { false }

  before do
    @config = Jekyll::Configuration.from(
      source: './test/site',
      destination: './temp',
      plugins: ['jekyll-rpg'],
      theme: 'minima',
      dm_mode: dm_mode,
      refs: refs,
      collections: {
        'gods' => { output: true },
        'history' => { output: true }
      }
    )
    @site = Jekyll::Site.new(@config)
    @site.reset
    @site.read
  end

  context 'with defaults' do
    it 'makes a graph with nodes representing links between pages' do
      expect(
        @site.data['graph'][0]['reference_name']
      ).to eq('Slaying of Bethany')
    end

    it 'puts the references on documents' do
      expect(
        site_doc_named('Bethany').data['referenced_by']['history']
      ).to eq ['[Slaying of Bethany](/history/slaying_of_bethany)']
    end

    it 'does not show references from DM material' do
      expect(
        site_doc_named('Bethany').data['referenced_by']['gods']
      ).to eq nil
    end

    it 'generates a list of broken links' do
      expect(
        @site.data['broken_links'].find do |link|
          link['reference_link'] == '[Bruce](/gods/bruce)'
        end['reference_slug']
      ).to eq('bruce')
    end
  end

  context 'with refs at a site level' do
    let(:refs) { true }
    let(:bethany) { site_doc_named('Bethany').content }

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
    let(:dm_mode) { true }

    it 'does shows references from DM material' do
      print @site.data['dm_mode']
      expect(
        site_doc_named('Bethany').data['referenced_by']['gods']
      ).to eq ['[Nega Bruce](/gods/nega_bruce)']
    end
  end
end

def site_doc_named(name)
  @site.documents.find { |doc| doc.data['name'] == name }
end
