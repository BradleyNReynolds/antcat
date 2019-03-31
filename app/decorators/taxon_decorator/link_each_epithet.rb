class TaxonDecorator::LinkEachEpithet
  include Service
  include Formatters::ItalicsHelper

  def initialize taxon
    @taxon = taxon
  end

  # This links the different parts of the binomial name. Only applicable to
  # species and below, since higher ranks consists of a single word.
  def call
    return @taxon.decorate.link_to_taxon unless @taxon.is_a? SpeciesGroupTaxon

    string = genus_link @taxon

    if @taxon.is_a? Species
      return string << header_link(@taxon, @taxon.name.epithet_html.html_safe)
    end

    species = @taxon.species
    if species
      string << header_link(species, species.name.epithet_html.html_safe)
      string << ' '.html_safe
      string << header_link(@taxon, italicize(@taxon.name.subspecies_epithets))
    else
      string << header_link(@taxon, italicize(@taxon.name.epithets))
    end

    string
  end

  private

    def genus_link taxon
      # Link name of the genus, but add dagger per to taxon's fossil status.
      label = taxon.genus.name.to_html_with_fossil @taxon.fossil?
      taxon.genus.decorate.link_to_taxon_with_label(label.html_safe) << " "
    end

    def header_link taxon, label
      taxon.decorate.link_to_taxon_with_label label
    end
end