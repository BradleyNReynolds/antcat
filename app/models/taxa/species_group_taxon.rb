# NOTE: This is the superclass of `Species`, `Subspecies` and `Infrasubspecies`, not to
# be confused with "species group" or "species-group name" as used in taxonomy.

class SpeciesGroupTaxon < Taxon
  belongs_to :subfamily
  belongs_to :genus
  belongs_to :subgenus

  validates :genus, presence: true

  before_create :set_subfamily # TODO: Remove callback.

  def recombination?
    # TODO: Check if this is true.
    # To avoid `NoMethodError` for records with protonyms above genus rank.
    protonym_name = protonym.name
    return false unless protonym_name.respond_to?(:genus_epithet)

    name.genus_epithet != protonym_name.genus_epithet
  end

  private

    def set_subfamily
      self.subfamily = genus.subfamily if genus&.subfamily
    end
end
