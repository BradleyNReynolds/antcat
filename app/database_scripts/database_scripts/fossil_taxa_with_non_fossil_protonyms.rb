module DatabaseScripts
  class FossilTaxaWithNonFossilProtonyms < DatabaseScript
    def results
      Taxon.fossil.joins(:protonym).where(protonyms: { fossil: false }).includes(:protonym)
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :protonym
        t.rows do |taxon|
          [
            markdown_taxon_link(taxon),
            taxon.status,
            taxon.protonym.decorate.link_to_protonym
          ]
        end
      end
    end
  end
end

__END__

title: Fossil taxa with non-fossil protonyms
category: Protonyms

description: >
  This is not necessarily incorrect.

related_scripts:
  - FossilProtonymsWithNonFossilTaxa
  - FossilTaxaWithNonFossilProtonyms
  - NonFossilProtonymsWithFossilTaxa
  - NonFossilTaxaWithFossilProtonyms
