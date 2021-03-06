# frozen_string_literal: true

class TaxonBrowserPresenter
  include Rails.application.routes.url_helpers
  include ActionView::Helpers
  include IconHelper

  attr_private_initialize :taxon_browser

  def taxon_browser_taxon_link taxon
    label = (taxon.fossil? ? +'†' : +'') << taxon.name_epithet
    link_to label, catalog_path(taxon), class: [taxon.status.tr(' ', '-'), taxon.rank]
  end

  def toggle_invalid_or_valid_only_link
    label, show_param = if taxon_browser.show_invalid?
                          ['show valid only', Catalog::ToggleDisplaysController::VALID_ONLY]
                        else
                          ['show invalid', Catalog::ToggleDisplaysController::VALID_AND_INVALID]
                        end
    link_to append_refresh_icon(label), catalog_toggle_display_path(show: show_param), method: :put
  end

  def extra_tab_link tab_taxon, label, tab_display
    css = tab_display == taxon_browser.display ? "selected" : "smaller-white-label"
    tag.span link_to(label, catalog_path(tab_taxon, display: tab_display)), class: css
  end
end
