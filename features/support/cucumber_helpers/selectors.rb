module CucumberHelpers
  module Selectors
    def selector_for locator
      case locator

      # Navigation.
      when 'the desktop menu'
        "#desktop-menu"

      # Catalog.
      when 'the taxon browser'
        "#taxon_browser"
      when /^the (\w*) taxon browser tab$/
        find(:link, $1)[:href]
      when 'the protonym'
        "#taxon_description .headline > span.name"
      when 'the header'
        "div.header"
      when 'the headline'
        '.headline'

      # Catalog search.
      when 'the search results'
        "table"

      # Editor's Panel.
      when 'the feed'
        'table.activities'

      when 'the left side of the diff'
        all(".callout .diff")[0]
      when 'the right side of the diff'
        all(".callout .diff")[1]

      when /"(.+)"/
        $1

      else
        raise %(Can't find mapping from "#{locator}" to a selector)
      end
    end
  end
end

World CucumberHelpers::Selectors
