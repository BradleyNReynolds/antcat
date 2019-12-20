class Species < SpeciesGroupTaxon
  has_many :subspecies, dependent: :restrict_with_error

  def parent
    subgenus || genus
  end

  def parent= parent_taxon
    case parent_taxon
    when Subgenus
      self.subgenus = parent_taxon
      self.genus = parent_taxon.genus
    when Genus
      self.genus = parent_taxon
    else
      raise InvalidParent.new(self, parent_taxon)
    end
    self.subfamily = parent_taxon.subfamily
  end

  def update_parent new_parent
    # TODO: This does not update names of subspecies.
    raise TaxonHasSubspecies if subspecies.any?

    name.change_parent(new_parent.name) unless new_parent == parent
    self.parent = new_parent
    update_descendants
  end

  def children
    subspecies
  end

  def childrens_rank_in_words
    "subspecies"
  end

  private

    def update_descendants
      subspecies.each do |subspecies|
        subspecies.update(subfamily: subfamily, genus: genus)
      end
    end
end
