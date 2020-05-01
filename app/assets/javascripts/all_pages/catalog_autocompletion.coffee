$ ->
  taxa = new Bloodhound
    datumTokenizer: Bloodhound.tokenizers.whitespace
    queryTokenizer: Bloodhound.tokenizers.whitespace
    remote:
      url: '/catalog/autocomplete?q=%QUERY'
      wildcard: '%QUERY'

  taxaDataSet =
    name: 'taxa'
    limit: Infinity # NOTE: Bug in typeahead.js v0.11.1; limited on server-side anyway.
    displayKey: 'name'
    source: taxa.ttAdapter()
    templates:
      empty: '<div class="empty-message">No results</div>'
      suggestion: (taxon) ->
        "<p><span class='#{taxon.css_classes}'>#{taxon.name_with_fossil}</span> <small>#{taxon.author_citation}</small></p>"

  options =
    hint: true
    highlight: true
    minLength: 1

  $('input.typeahead-taxa-js-hook').typeahead(options, taxaDataSet)
    .on 'typeahead:selected', (_event, suggestion) ->
      window.location.href = suggestion.url
