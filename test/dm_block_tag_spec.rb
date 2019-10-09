# frozen_string_literal: true

require_relative 'spec_helper'

# End-to-end tests via Jekyll
describe 'DM Block Spec' do
  let(:site)    { create :site, renders: true }
  let(:bethany) { doc_named(site, 'Bethany').content }

  context 'with defaults' do
    it 'Does not contain text in DM block' do
      expect(bethany).not_to include('Jungus')
    end
  end

  context 'In DM Mode' do
    let(:site) { create :site, dm_mode: true, renders: true }

    it 'Contain text in DM block' do
      expect(bethany).to include('Jungus')
    end

    it 'Has a heading for the DM Note' do
      expect(bethany).to include('DM Note')
    end
  end
end
