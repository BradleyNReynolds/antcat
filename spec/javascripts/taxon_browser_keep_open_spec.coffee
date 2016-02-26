#= require taxon_browser_keep_open
#= require js.cookie

fixture.preload "taxon_browser_keep_open.html"

describe "Test Fixtures", ->
  it "loads fixtures", ->
    fixture.load "taxon_browser_keep_open.html"
    expect($ "#keep_taxon_browser_open").toBeChecked()

describe "TaxonBrowserKeepOpen", ->
  beforeEach ->
    fixture.load "taxon_browser_keep_open.html"
    Cookies.remove "browser_toggler"
    Cookies.remove "browser_keep_open"

  browserVisible = (value) -> Cookies.set "browser_toggler", "show": value

  keepOpen = (value) -> Cookies.set "browser_keep_open", "keep_open": value

  browserIsVisible = -> expect(Cookies.getJSON("browser_toggler").show).toBe true

  browserIsHidden = -> expect(Cookies.getJSON("browser_toggler").show).toBe false

  describe "states/cookies", ->
    describe "browser hidden", ->
      it "hidden + off = HIDE", ->
        browserVisible false
        keepOpen false
        new TaxonBrowserKeepOpen()
        browserIsHidden()

      it "hidden + on = HIDE", ->
        browserVisible false
        keepOpen true
        new TaxonBrowserKeepOpen()
        browserIsHidden()

    describe "browser visible", ->
      it "visible + off = HIDE", ->
        browserVisible true
        keepOpen false
        new TaxonBrowserKeepOpen()
        browserIsHidden()

      it "visible + on = SHOW", ->
        browserVisible true
        keepOpen true
        new TaxonBrowserKeepOpen()
        browserIsVisible()

  describe "keep open checkbox", ->
    it "doesn't check the box if cookies are undefined", ->
      new TaxonBrowserKeepOpen()
      expect($ "#keep_taxon_browser_open").not.toBeChecked()

    it "checks the box if cookies tells it to", ->
      keepOpen true
      new TaxonBrowserKeepOpen()
      expect($ "#keep_taxon_browser_open").toBeChecked()
