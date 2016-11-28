module TaxonBrowserHelper
  def taxon_browser_link taxon
    classes = css_classes_for_rank(taxon)
    classes << css_classes_for_status(taxon)
    link_to taxon.taxon_label, catalog_path(taxon), class: classes
  end

  def toggle_valid_only_link
    showing = !session[:show_invalid]

    label = showing ? "show invalid" : "show valid only"
    link_to label, catalog_options_path(valid_only: showing)
  end

  # Some taxon browser tabs have extra links which
  # only are applicable to some ranks.
  def extra_tab_links selected
    links = []

    case selected
    when Family, Subfamily
      links << extra_tab_link(selected, "All genera", "all_genera_in_#{selected.rank}")
      links << incertae_sedis_link(selected)
    when Genus
      links << extra_tab_link(selected, "All taxa", "all_taxa_in_#{selected.rank}")
      links << subgenera_link(selected)
    end

    links.reject(&:blank?).join.html_safe
  end

 private
    # Only for Formicidae/subfamilies.
    def incertae_sedis_link selected
      return unless selected.genera_incertae_sedis_in.exists?
      extra_tab_link selected, "Incertae sedis", "incertae_sedis_in_#{selected.rank}"
    end

    # Only shown if the taxon is a genus with displayable subgenera
    # For example Lasius, http://localhost:3000/catalog/429161)
    def subgenera_link selected
      return unless selected.displayable_subgenera.exists?
      extra_tab_link selected, "Subgenera", :subgenera_in_genus
    end

    def extra_tab_link selected, label, param
      css = if @taxon_browser.display == param.to_sym
              "upcase selected"
            else
              "upcase white-label"
            end

      content_tag :li do
        content_tag :span, class: css do
          link_to label, catalog_path(selected, display: param)
        end
      end
    end
end
