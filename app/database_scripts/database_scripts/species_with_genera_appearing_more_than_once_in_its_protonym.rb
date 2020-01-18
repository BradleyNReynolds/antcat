module DatabaseScripts
  class SpeciesWithGeneraAppearingMoreThanOnceInItsProtonym < DatabaseScript
    def self.record_in_results? taxon
      return false unless taxon.is_a?(Species)
      taxon.protonym.taxa.where(type: 'Species').
        to_a.count { |t| t.name.genus_epithet == taxon.name.genus_epithet } > 1
    end

    def results
      dups = Species.joins(:name).group("protonym_id, SUBSTRING_INDEX(names.name, ' ', 1)").having("COUNT(taxa.id) > 1")
      Species.where(protonym_id: dups.select(:protonym_id)).distinct
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :origin, :protonym
        t.rows do |taxon|
          [
            markdown_taxon_link(taxon),
            taxon.status,
            origin_warning(taxon),
            taxon.protonym.decorate.link_to_protonym
          ]
        end
      end
    end
  end
end

__END__

category: Catalog
tags: [new!]

issue_description: The genus of this species appears more than once among the protonym's taxa.

description: >
  This script is the reverse of %dbscript:ProtonymsWithMoreThanOneSpeciesInTheSameGenus

related_scripts:
  - ProtonymsWithMoreThanOneSpeciesInTheSameGenus
  - SpeciesWithGeneraAppearingMoreThanOnceInItsProtonym
