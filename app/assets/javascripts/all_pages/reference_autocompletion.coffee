$ ->
  authors = new Bloodhound
    datumTokenizer: Bloodhound.tokenizers.whitespace
    queryTokenizer: Bloodhound.tokenizers.whitespace
    remote:
      url: '/authors/autocomplete?term=%QUERY'
      wildcard: '%QUERY'

  authorsDataSet =
    name: 'authors'
    limit: 5 # NOTE limited on client-side to not interfer with other author autocompletions and because lazy.
    display: (authorName) -> "author:'#{authorName}'"
    source: authors.ttAdapter()
    templates:
      header: '<h5 class="autocompletion-header">Author results <small>(top 5)</small></h5>'
      empty:
        '<div class="empty-message">' +
        'Unable to find any authors that match the current query. ' +
        '</div>'
      suggestion: (authorName) ->
        "<p>#{authorName}</p>"

  references = new Bloodhound
    datumTokenizer: Bloodhound.tokenizers.whitespace
    queryTokenizer: Bloodhound.tokenizers.whitespace
    remote:
      url: '/references/autocomplete?reference_q=%QUERY'
      wildcard: '%QUERY'

  referencesDataSet =
    name: 'references'
    limit: Infinity # TODO bug in typeahead.js v0.11.1; limited on server-side anyway.
    displayKey: 'search_query'
    source: references.ttAdapter()
    templates:
      header: '<h5 class="autocompletion-header">Reference results <small>(top 10)</small></h5>'
      empty:
        '<div class="empty-message">' +
        'Unable to find any references that match the current query.<br>' +
        '<small>Maybe try with a keyword? Examples: "author:bolton", "year:2003".</small>' +
        '</div>'
      suggestion: (reference) ->
        '<p>' + reference.author + ' (' + reference.year + ')<br><small>' + reference.title + '</small></p>'

  options =
    highlight: true
    minLength: 2

   $('input.typeahead-references-js').typeahead(options, authorsDataSet, referencesDataSet)
    .on 'typeahead:selected', (e) ->
      # To make clicking on a suggestion or pressing Enter submit the form.
      e.target.form.submit()