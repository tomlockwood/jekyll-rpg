# frozen_string_literal: true

require_relative 'spec_helper'

# End-to-end tests via Jekyll
describe 'Unwritten links' do
  let(:site)    { create :site, renders: true }
  let(:bethany) { doc_named(site, 'Bethany').content }

  it 'strikes through the broken links' do
    expect(bethany).to include(
      '<del><a href="/faults/bethany">All bethany’s faults</a></del>'
    )
    expect(bethany).to include(
      '<del><a href="/history/rise_of_bethany">rise</a></del>'
    )
  end
end
