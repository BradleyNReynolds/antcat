module DatabaseScripts
  class ProtonymsWithTaxaWithIncompatibleStatuses < DatabaseScript
    TYPES = [
      Status::VALID,
      Status::SYNONYM,
      Status::HOMONYM,
      Status::EXCLUDED_FROM_FORMICIDAE
    ]

    def self.looks_like_a_false_positive? protonym
      Protonym.all_statuses_same?(protonym.taxa) &&
        Protonym.all_taxa_above_genus_and_of_unique_different_ranks?(protonym.taxa)
    end

    def results
      Protonym.joins(:taxa).group(:protonym_id).having(<<~SQL, TYPES)
        COUNT(CASE WHEN status IN (?) THEN status ELSE NULL END) > 1
      SQL
    end

    def render
      as_table do |t|
        t.header :protonym, :authorship, :ranks_of_taxa, :statuses_of_taxa, :looks_like_a_false_positive?
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            protonym.authorship.reference.keey,
            protonym.taxa.pluck(:type).join(', '),
            protonym.taxa.pluck(:status).join(', '),
            (self.class.looks_like_a_false_positive?(protonym) ? 'Yes' : bold_warning('No'))
          ]
        end
      end
    end
  end
end

__END__

category: Catalog
tags: []

issue_description:

description: >
  Incompatible statuses:


  * Valid

  * Synonym

  * Homonym

  * Excluded from Formicidae


  Compatible statuses:


  * Obsolete combination

  * Unavailable misspelling


  Not checked but should probably be checked:


  * Unidentifiable

  * Unavailable

  * Unavailable uncategorized

related_scripts:
  - ProtonymsWithMoreThanOneOriginalCombination
  - ProtonymsWithMoreThanOneSpeciesInTheSameGenus
  - ProtonymsWithMoreThanOneSynonym
  - ProtonymsWithMoreThanOneTaxonWithAssociatedHistoryItems
  - ProtonymsWithMoreThanOneValidTaxon
  - ProtonymsWithMoreThanOneValidTaxonOrSynonym
  - ProtonymsWithTaxaWithIncompatibleStatuses
  - ProtonymsWithTaxaWithMoreThanOneCurrentValidTaxon
  - ProtonymsWithTaxaWithMoreThanOneTypeTaxon

  - TypeTaxaAssignedToMoreThanOneTaxon