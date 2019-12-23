module DatabaseScripts
  class NonFossilProtonymsWithFossilTaxa < DatabaseScript
    def results
      Protonym.extant.joins(:taxa).where(taxa: { fossil: true }).includes(:taxa)
    end

    def render
      as_table do |t|
        t.header :protonym, :taxa
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            protonym.taxa.map(&:link_to_taxon).join('<br>')
          ]
        end
      end
    end
  end
end

__END__

title: Non-fossil protonyms with fossil taxa
category: Protonyms

issue_description: (possibly ok) This protonym is not fossil, but one of its taxa is.

description: >
  This is not necessarily incorrect.

related_scripts:
  - FossilProtonymsWithNonFossilTaxa
  - FossilTaxaWithNonFossilProtonyms
  - NonFossilProtonymsWithFossilTaxa
  - NonFossilTaxaWithFossilProtonyms
