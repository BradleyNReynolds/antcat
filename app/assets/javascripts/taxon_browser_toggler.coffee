# Responsible for:
# * Toggle show/hide (handlers attached to the `TOGGLERS`):
#   * Toggle visibility
#   * Update the togglers' labels after toggling
#   * Save current visibility state in a cookie
# * On init: read cookie, and hide browser if necessary (disabled in test)

class @TaxonBrowserToggler
  # Element we want to show/hide
  TAXON_BROWSER = "#taxon_browser"

  # Elements that can open/close the browser
  TOGGLERS = "#desktop-toggler, #mobile-toggler, #tiny-toggler"

  # Don't include "Hide/Show" in the tiny toggler's label -- it's too tiny!!
  LABELS_TO_UPDATE = "#desktop-toggler, #mobile-toggler"

  constructor: ->
    @_isVisible = @_getCookie() || false
    @_setToVisibleIfTestEnv()
    @_hideUnlessVisible()
    @_setClickHandlers TOGGLERS

  toggle: ->
    $(TAXON_BROWSER).slideToggle 250
    @_isVisible = !@_isVisible
    @_setCookie @_isVisible
    @_updateLabels LABELS_TO_UPDATE

  _getCookie: -> Cookies.getJSON("browser_toggler")?.show

  _setCookie: (isVisible) -> Cookies.set("browser_toggler", "show": isVisible)

  _setClickHandlers: (elements) -> $(elements).click => @toggle()

  _updateLabels: (elements) ->
    verb = if @_isVisible then "Hide" else "Show"
    $(elements).text "#{verb} Taxon Browser"

  _hideUnlessVisible: ->
    unless @_isVisible
      $(TAXON_BROWSER).hide()
      @_updateLabels LABELS_TO_UPDATE

  # Always show in tests, unless scenario is tagged with @taxon_browser.
  _setToVisibleIfTestEnv: ->
    @_isVisible = true if AntCat.taxon_browser_test_hack
