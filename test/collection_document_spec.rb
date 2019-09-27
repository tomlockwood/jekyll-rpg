# frozen_string_literal: true

require_relative 'spec_helper'

# CollectionDocument
describe 'CollectionDocument' do
  let(:collection_document) { build :collection_document }

  it 'returns a markdown link' do
    expect(collection_document.markdown_link).to eq '[Bethany](/gods/bethany)'
  end
end
