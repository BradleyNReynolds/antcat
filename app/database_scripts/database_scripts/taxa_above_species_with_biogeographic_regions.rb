module DatabaseScripts
  class TaxaAboveSpeciesWithBiogeographicRegions < DatabaseScript
    def results
      Taxon.exclude_ranks(Species, Subspecies).
        where.not(biogeographic_region: ["", nil])
    end

    def render
      as_table do |t|
        t.header :taxon, :biogeographic_region

        t.rows { |taxon| [markdown_taxon_link(taxon), taxon.biogeographic_region] }
      end
    end
  end
end

__END__
topic_areas: [catalog]
tags: [regression-test]
issue_description: This taxon has a biogeographic region, but it is not a species or subspecies.