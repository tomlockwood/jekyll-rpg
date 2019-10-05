# frozen_string_literal: true

require 'factory_bot'

FactoryBot.define do
  factory :collection_document, class: JekyllRPG::CollectionDocument do
    name       { 'Bethany' }
    collection { 'gods' }
    slug       { 'bethany' }
    viewable    { true }
  end
end
