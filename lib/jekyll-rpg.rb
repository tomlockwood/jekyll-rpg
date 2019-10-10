# frozen_string_literal: true

require 'jekyll'
require_relative 'references'

# Generates reference information for Jekyll Site
module JekyllRPG
  # Bi-directional page links
  Jekyll::Hooks.register :site, :post_read do |site|
    References.new(site)
  end

  # DM tag to hide content
  class RenderDMContent < Liquid::Block
    def render(context)
      text = ''
      if context.registers[:site].config['dm_mode']
        text += "> # DM Note: \n"
        super.each_line do |line|
          text += '>> ' + line
        end
      end
      text
    end
  end
end

Liquid::Template.register_tag('dm', JekyllRPG::RenderDMContent)
