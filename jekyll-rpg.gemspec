# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'jekyll-rpg'
  s.version     = '0.0.6'
  s.date        = '2019-10-05'
  s.summary     = 'Jekyll plugin for managing RPG information for DMs'
  s.description = ''
  s.authors     = ['Tom Lockwood']
  s.email       = 'tom@lockwood.dev'
  s.files       = [
    'lib/collection_document.rb',
    'lib/edge.rb',
    'lib/graph.rb',
    'lib/jekyll-rpg.rb',
    'lib/markdown_link.rb',
    'lib/reference_table.rb',
    'lib/references.rb'
  ]
  s.homepage =
    'https://github.com/tomlockwood/jekyll-rpg'
  s.license = 'MIT'
  s.required_ruby_version = '>= 2.6.1'

  s.add_dependency 'jekyll', '>= 3.8.6', '~> 4.0.0'
  s.add_development_dependency 'factory_bot', '~> 5.0.2'
  s.add_development_dependency 'pry', '~> 0.12.2'
  s.add_development_dependency 'rspec', '~> 3.8.0'
end
