module DatabaseScripts
  class SubspeciesWithSpeciesEpithetsNotMatchingItsSpeciesEpithet < DatabaseScript
    def results
      Subspecies.joins(:name).self_join_on(:species).
        joins("JOIN names species_names ON species_names.id = taxa_self_join_alias.name_id").
        where(<<~SQL)
          SUBSTRING_INDEX(SUBSTRING_INDEX(names.name, ' ', 2), ' ', -1) !=
          SUBSTRING_INDEX(SUBSTRING_INDEX(species_names.name, ' ', 2), ' ', -1)
        SQL
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :species_name
        t.rows do |taxon|
          [
            markdown_taxon_link(taxon),
            taxon.status,
            taxon.species.name_html_cache
          ]
        end
      end
    end
  end
end

__END__

description: >

tags: []
topic_areas: [catalog]
related_scripts:
  - SpeciesDisagreeingWithGenusRegardingSubfamily
  - SubspeciesDisagreeingWithSpeciesRegardingGenus
  - SubspeciesDisagreeingWithSpeciesRegardingSubfamily
  - SpeciesWithGenusEpithetsNotMatchingItsGenusEpithet
  - SubspeciesWithGenusEpithetsNotMatchingItsGenusEpithet
  - SubspeciesWithSpeciesEpithetsNotMatchingItsSpeciesEpithet