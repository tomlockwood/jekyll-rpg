# frozen_string_literal: true

require 'bundler'
Bundler.setup

require 'factory_bot'
require 'jekyll-rpg'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end
end

def doc_named(site, name)
  site.jekyll.documents.find { |doc| doc.data['name'] == name }
end
