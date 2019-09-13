require 'jekyll'

describe 'Make Jekyll-RPG site' do
    before do
        @config = Jekyll::Configuration.from({})
        @site = Jekyll::Site.new(@config)
    end

    it 'makes a site lol' do
        print @site.data
    end
end