class Species < SpeciesGroupTaxon
  has_many :subspecies

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
    name.change_parent(new_parent.name) unless new_parent == parent
    self.parent = new_parent
  end

  def children
    subspecies
  end

  def childrens_rank_in_words
    "subspecies"
  end

  def statistics valid_only: false
    get_statistics [:subspecies], valid_only: valid_only
  end
end
