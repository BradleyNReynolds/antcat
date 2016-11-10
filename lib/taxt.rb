# Last relics of a former empire.
#
# Code for parsing taxts into HTML/text have been moved to `TaxtPresenter`:
#   `Taxt.to_string`           --> `TaxtPresenter#to_html`
#   `Taxt.to_display_sentence` --> `TaxtPresenter#to_text`
#
# Code related to editing in the JS taxt editor have been moved to `TaxtConverter`:
#   `Taxt.to_editable`   --> `TaxtConverter.to_editor_format`
#   `Taxt.from_editable` --> `TaxtConverter.from_editor_format`
#
#   The names of these haven't changed:
#   `.to_editable_reference
#   `.to_editable_taxon
#   `.to_editable_name name
#
#   Also haven't changed, but private, so please ignore.
#   `Taxt.to_editable_tag`
#   `Taxt.id_for_editable`
#   `Taxt.id_from_editable`

module Taxt
  TAXT_FIELDS = [
    [Taxon, [:type_taxt, :headline_notes_taxt, :genus_species_header_notes_taxt]],
    [Citation, [:notes_taxt]],
    [ReferenceSection, [:title_taxt, :subtitle_taxt, :references_taxt]],
    [TaxonHistoryItem, [:taxt]]
  ]
end
