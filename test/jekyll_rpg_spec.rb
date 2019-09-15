# frozen_string_literal: true

require 'jekyll'
require 'pry'

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
    @site.process
  end

  context 'with defaults' do
    it 'makes a graph with nodes representing links between pages' do
      expect(@site.data['graph']['gods']['bethany']['history']['slaying_of_bethany']).to eq('Slaying of Bethany')
    end

    it 'puts the references on documents' do
      expect(site_doc_named('Bethany').data['referenced_by']['history']).to eq ['[Slaying of Bethany](/history/slaying_of_bethany)']
    end

    it 'generates a list of broken links' do
      expect(@site.data['broken_links'].find { |link| link['url'] == '/gods/bruce' }['slug']).to eq('bruce')
    end
  end

  context 'with refs at a site level' do
    let(:refs) { true }
    let(:bethany) { site_doc_named('Bethany').content }

    it 'puts a table with references on the documents' do
      expect(bethany).to include('<table>')
    end

    it 'puts a link to the referencing document on the document' do
      expect(bethany).to include('<a href="/history/slaying_of_bethany">Slaying of Bethany</a>')
    end

    it 'does not include a collection row for a collection that has no refs to the doc' do
      expect(bethany).not_to include('Gods')
    end
  end
end

def site_doc_named(name)
  @site.documents.find { |doc| doc.data['name'] == name }
end
