# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'jekyll-rpg'
  s.version     = '0.0.0'
  s.date        = '2019-08-13'
  s.summary     = 'Jekyll plugin for managing RPG information for DMs'
  s.description = ''
  s.authors     = ['Tom Lockwood']
  s.email       = 'tom@lockwood.dev'
  s.files       = ['lib/jekyll-rpg.rb']
  s.homepage    =
    'https://rubygems.org/gems/jekyll-rpg'
  s.license = 'MIT'

  s.add_dependency "jekyll"
  s.add_dependency "pry"
end
