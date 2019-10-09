# frozen_string_literal: true

require 'factory_bot'
require 'jekyll'

FactoryBot.define do
  factory :site, class: OpenStruct do
    transient do
      renders { false }
    end
    source      { './test/site' }
    destination { './temp' }
    plugins     { ['jekyll-rpg'] }
    theme       { 'minima' }
    dm_mode     { false }
    refs        { false }
    collections do
      { 'gods' => { output: true },
        'history' => { output: true } }
    end
    jekyll do
      config = Jekyll::Configuration.from(
        source: source,
        destination: destination,
        plugins: plugins,
        theme: theme,
        dm_mode: dm_mode,
        refs: refs,
        collections: collections
      )
      Jekyll::Site.new(config)
    end

    after(:create) do |site, evaluator|
      site.jekyll.reset
      site.jekyll.read
      if evaluator.renders
        site.jekyll.generate
        site.jekyll.render
      end
    end
  end
end
