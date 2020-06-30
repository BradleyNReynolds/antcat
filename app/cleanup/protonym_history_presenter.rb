# frozen_string_literal: true

# TODO: Temporary(tm) code for migrating history items to protonyms.

class ProtonymHistoryPresenter
  def initialize taxon
    @taxon = taxon
    @protonym = taxon.protonym
  end

  # Warning.
  def any_unreachable_self_owned_items?
    !show_protonym_items? && taxon.history_items.exists?
  end

  # Warning.
  def protonym_item_belonging_to_multiple_taxa?
    protonym.history_items.pluck(:taxon_id).uniq.size > 1
  end

  def any_taxon_or_protonym_items?
    protonym.history_items.exists?
  end

  def only_items_self_owned_by_taxon?
    items_excluding_self_owned.empty?
  end

  def only_protonym_items?
    taxon.history_items.empty?
  end

  def items_excluding_self_owned
    protonym.history_items.where.not(taxon: taxon)
  end

  def any_rank_specific_items_excluding_self_owned?
    items_excluding_self_owned.where.not(rank: nil).exists?
  end

  def show_rank_specific_item? history_item, catalog_taxon
    history_item.rank == catalog_taxon.type
  end

  def show_protonym_items?
    taxon.status.in?(Status::DISPLAY_HISTORY_ITEMS_VIA_PROTONYM_STATUSES)
  end

  def proposed_history_items
    return TaxonHistoryItem.none unless show_protonym_items?
    protonym.history_items.where(rank: [taxon.type, nil])
  end

  # TODO: This is for a future column for family/subfamily/tribe trios.
  # rubocop:disable Style/MultipleComparison
  def rank_field_required? catalog_taxon, history_item_owner_taxon
    ranks = [catalog_taxon.type, history_item_owner_taxon.type].sort

    ranks == [Rank::FAMILY, Rank::SUBFAMILY] ||
      ranks == [Rank::FAMILY, Rank::TRIBE] ||
      ranks == [Rank::SUBFAMILY, Rank::TRIBE]
  end
  # rubocop:enable Style/MultipleComparison

  private

    attr_reader :taxon, :protonym
end
