Citrus.load "#{__dir__}/author_grammar"

module Parsers::AuthorParser

  def self.parse! string
    return {:names => []} unless string.present?

    match = Parsers::AuthorGrammar.parse(string, :consume => false)
    result = match.value
    string.gsub! /#{Regexp.escape match}/, ''

    {:names => result[:names], :suffix => result[:suffix]}
  end

  def self.parse string
    string &&= string.dup
    parse! string
  end

  def self.get_name_parts string
    parts = {}
    return parts unless string.present?
    matches = string.match /(.*?), (.*)/
    unless matches
      parts[:last] = string
    else
      parts[:last] = matches[1]
      parts[:first_and_initials] = matches[2]
    end
    parts
  end

end
