# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'jekyll-rpg'
  s.version     = '0.0.1'
  s.date        = '2019-09-05'
  s.summary     = 'Jekyll plugin for managing RPG information for DMs'
  s.description = ''
  s.authors     = ['Tom Lockwood']
  s.email       = 'tom@lockwood.dev'
  s.files       = ['lib/jekyll-rpg.rb']
  s.homepage    =
    'https://github.com/tomlockwood/jekyll-rpg'
  s.license = 'MIT'
  s.required_ruby_version = '>= 2.6.1'

  s.add_dependency 'jekyll', '~> 3'
end
